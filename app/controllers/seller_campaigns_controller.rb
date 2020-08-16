# frozen_string_literal: true

class SellerCampaignsController < ApplicationController
  before_action :set_seller

  # GET /sellers/:seller_id/campaigns
  def index
    @campaigns = if params[:active].present?
                   valid_campaigns.order(:end_date).active(params[:active])
                 else
                   valid_campaigns.order(:end_date)
    end

    json_response(campaigns_json)
  end

  private

  def set_seller
    @seller = Seller.find_by!(seller_id: params[:seller_id])
  end

  def campaigns_json
    @campaigns.map { |c| campaign_json campaign: c }
  end

  def campaign_json(campaign: @campaign)
    ret = campaign.as_json
    ret['amount_raised'] = campaign.amount_raised
    ret['last_contribution'] = campaign.last_contribution
    ret['seller_id'] = campaign.seller.seller_id
    ret
  end

  def valid_campaigns
    Campaign.where(
      valid: true,
      seller_id: @seller.id,
    )
  end
end
