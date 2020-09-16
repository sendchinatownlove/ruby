# frozen_string_literal: true

class CampaignsController < ApplicationController
  before_action :set_campaign, only: %i[show update]

  # GET /campaigns
  def index
    @campaigns = if params[:active].present?
                   valid_campaigns.order(:end_date).active(params[:active])
                 else
                   valid_campaigns.order(:end_date).all
    end

    json_response(campaigns_json)
  end

  # GET /campaigns/:id
  def show
    json_response(campaign_json)
  end

  # POST /campaigns
  def create
    @campaign = Campaign.create!(create_params)
    if params[:has_square_fee]
      @fee = Fee.find(1)
      @campaign.fees << @fee
      @fee.campaigns << @campaign
    end
    json_response(campaign_json, :created)
  end

  # PUT /campaigns/:id
  def update
    @campaign.update(update_params)
    json_response(campaign_json)
  end

  private

  def create_params
    params.require(:end_date)
    params.require(:location_id)
    params.require(:seller_id)
    params.require(:distributor_id)

    ret = params.permit(
      :active,
      :description,
      :end_date,
      :price_per_meal,
      :target_amount,
      gallery_image_urls: []
    )

    set_location
    set_seller
    set_distributor
    ret[:location_id] = @location.id
    ret[:seller_id] = @seller.id
    ret[:distributor_id] = @distributor.id

    ret
  end

  def update_params
    params.permit(
      :active,
      :description,
      :valid,
      :price_per_meal,
      gallery_image_urls: []
    )
  end

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def set_location
    @location = Location.find(params[:location_id])
  end

  def set_seller
    @seller = Seller.find_by!(seller_id: params[:seller_id])
  end

  def set_distributor
    @distributor = Distributor.find(params[:distributor_id])
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
    Campaign.where(valid: true)
  end
end
