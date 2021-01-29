# frozen_string_literal: true

class RedemptionsController < ApplicationController
  before_action :set_contact
  before_action :set_reward

  # POST /redemptions
  def create
    ActiveRecord::Base.transaction do
      receipts_to_redeem = CrawlReceipt.where(contact: @contact, redemption: nil)

      if receipts_to_redeem.size < 3
        raise TicketRedemptionError, 'Contact is trying to redeem with less than 3 redeemable receipts'
      end

      @redemption = Redemption.create!(create_params)

      # associate the first 3 redeemable receipts with this redemption
      (0..2).each do |i|
        receipts_to_redeem[i].update!(redemption: @redemption)
      end

      json_response(@redemption, :created)
    end
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
