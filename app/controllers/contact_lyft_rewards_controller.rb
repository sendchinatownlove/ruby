# frozen_string_literal: true

class ContactLyftRewardsController < ApplicationController
  before_action :set_contact

  # GET /contacts/:contact_id/lyft_rewards
  def index
    lyft_reward = LyftReward.find_by!(contact: @contact, state: 'verified')
    json_response(lyft_reward.as_json(only: :code))
  end

  # POST /contacts/:contact_id/lyft_rewards
  def create
    ActiveRecord::Base.transaction do
      unless @contact.is_eligible_for_lyft_reward
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
          contact_id: @contact.id,
          email: @contact.email,
          token: token
        }
      )

      lyft_reward.update(
        contact: @contact,
        expires_at: Time.now + 72.hours,
        state: 'delivered',
        token: token
      )
    end
  end

  # POST /contacts/:contact_id/lyft_rewards/:token/redeem
  def redeem
    lyft_reward = nil

    ActiveRecord::Base.transaction do
      lyft_reward = LyftReward.find_by!(
        contact: @contact,
        token: params[:token]
      )

      unless lyft_reward.state == 'delivered' && Time.now < lyft_reward.expires_at
        raise ActiveRecord::RecordNotFound
      end

      lyft_reward.update(
        state: 'verified'
      )
    end

    json_response(lyft_reward.as_json(only: :code))
  end

  private

  def set_contact
    @contact = Contact.find(params[:contact_id])
  end
end
