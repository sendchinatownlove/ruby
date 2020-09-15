# frozen_string_literal: true

class ContactLyftRewardsController < ApplicationController
  # POST /contacts/:contact_id/lyft_rewards
  def create
    ActiveRecord::Base.transaction do
      contact = Contact.find(params[:contact_id])

      unless contact.is_eligible_for_lyft_reward
        raise InvalidLyftRewardsContactError, 'Contact is not eligible for Lyft Rewards.'
      end

      rel = LyftReward.arel_table
      lyft_reward = LyftReward
                    .where(
                      rel[:state].eq('new')
                        .or(
                          rel[:state].eq('delivered').and(rel[:expires_at].lt(Date.today))
                        )
                    ).first

      token = 'token_' + ULID.generate

      EmailManager::ContactLyftRewardsSender.call(
        {
          contact_id: contact.id,
          email: contact.email,
          token: token
        }
      )

      lyft_reward.update(
        contact: contact,
        expires_at: Time.now + 72.hours,
        state: 'delivered',
        token: token
      )
    end
  end
end
