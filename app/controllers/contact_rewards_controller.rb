# frozen_string_literal: true

class ContactRewardsController < ApplicationController
  # POST /contacts/:contact_id/rewards
  def create
    token = 'token_' + ULID.generate
    contact = Contact.find(params[:contact_id])
    contact.update(
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
