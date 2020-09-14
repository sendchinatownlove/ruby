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
    if has_redeemed_lyft_reward
      false
    end

    available_rewards = LyftRewards
                        .where(state)
  end  

  def has_redeemed_lyft_reward
    LyftRewards.where(contact_id: id, state: 'verified').count > 0
  end
end
