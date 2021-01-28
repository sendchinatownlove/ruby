# frozen_string_literal: true

class RedemptionsController < ApplicationController
  before_action :set_contact
  before_action :set_reward

  # POST /redemptions
  def create
    if CrawlReceipt.where(contact: @contact).size < 3
      raise TicketRedemptionError, 'Contact is trying to redeem with less than 3 receipts'
    end

    @redemption = Redemption.create!(create_params)

    json_response(@redemption, :created)
  end

  private

  def create_params
    params.require(:contact_id)
    params.require(:reward_id)
    params.permit(
      :contact_id,
      :reward_id
    )
  end

  def set_contact
    @contact = Contact.find(params[:contact_id])
  end

  def set_reward
    @reward = Reward.find(params[:reward_id])
  end
end
