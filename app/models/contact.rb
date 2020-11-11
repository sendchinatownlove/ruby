# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id                              :bigint           not null, primary key
#  email                           :string           not null
#  expires_at                      :datetime
#  instagram                       :string
#  is_subscribed                   :boolean          default(TRUE), not null
#  name                            :string
#  rewards_redemption_access_token :string
#
# Indexes
#
#  index_contacts_on_email  (email) UNIQUE
#
class Contact < ApplicationRecord
  has_many :items, class_name: 'Item', foreign_key: 'purchaser_id'
  has_many :gift_card_details, class_name: 'GiftCardDetail', foreign_key: 'recipient_id'

  validates_uniqueness_of :email
  validates :is_subscribed, inclusion: { in: [true, false] }

  def is_eligible_for_lyft_reward
    unless !has_claimed_or_redeemed_lyft_reward && has_redeemed_lyft_sponsored_ticket
      return false
    end

    rel = LyftReward.arel_table
    LyftReward.where(
      rel[:state].eq('new')
        .or(
          rel[:state].eq('delivered').and(rel[:expires_at].lt(Date.today))
        )
    ).count > 0
  end

  def has_redeemed_lyft_reward
    LyftReward.where(contact_id: id, state: 'verified').count > 0
  end

  private

  def has_claimed_or_redeemed_lyft_reward
    return true if has_redeemed_lyft_reward

    rel = LyftReward.arel_table

    LyftReward
      .where(
        rel[:contact_id].eq(id)
          .and(
            rel[:state].eq('delivered').and(rel[:expires_at].gteq(Date.today))
          )
      ).count > 0
  end

  def has_redeemed_lyft_sponsored_ticket
    lyft_rewards_launch_date = Date.new(2020, 9, 18)
    Ticket
      .joins(:participating_seller)
      .where(
        tickets: {
          contact_id: id
        },
        participating_sellers: {
          is_lyft_sponsored: true
        }
      )
      .where('tickets.associated_with_contact_at >= ?', lyft_rewards_launch_date)
      .count > 0
  end
end
