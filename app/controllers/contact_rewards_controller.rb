# frozen_string_literal: true

class ContactRewardsController < ApplicationController
  # POST /contacts/:contact_id/rewards
  def create
    ActiveRecord::Base.transaction do
      contact = Contact.find(params[:contact_id])

      # If they've already requested an email within the last 30 minutes, use
      # the same token
      token = if contact.expires_at.present? && Time.now < contact.expires_at
                contact.rewards_redemption_access_token
              else
                # Otherwise generate a new one
                'token_' + ULID.generate
      end

      contact.update(
        expires_at: Time.now + 30.minutes,
        rewards_redemption_access_token: token
      )

      EmailManager::ContactRewardsSender.call(
        {
          contact_id: contact.id,
          email: contact.email,
          token: token
        }
      )
    end
  end
end
