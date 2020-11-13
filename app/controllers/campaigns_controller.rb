# frozen_string_literal: true

class CampaignsController < ApplicationController
  before_action :set_campaign, only: %i[show update]

  # GET /campaigns
  def index
    @campaigns = valid_campaigns.order(:end_date).all
    json_response(campaigns_json)
  end

  # GET /campaigns/:id
  def show
    json_response(campaign_json)
  end

  # POST /campaigns
  def create
    @campaign = Campaign.create!(create_params)
    json_response(campaign_json, :created)
  end

  # PUT /campaigns/:id
  def update
    @campaign.update(update_params)
    json_response(campaign_json)
  end

  # POST /campaigns/:id/seller_distributor
  def associate_seller_distributor
    CampaignsSellersDistributor.create!(associate_seller_distributor_params)
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
      :nonprofit_id,
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
      :nonprofit_id,
      gallery_image_urls: []
    )
  end

  def associate_seller_distributor_params
    params.require(:distributor_id)
    params.require(:seller_id)

    ret = params.permit(
      :distributor_id,
      :seller_id,
    )

    set_campaign
    set_distributor
    @seller = Seller.find(params[:seller_id])

    ret[:campaign_id] = @campaign.id
    ret[:distributor_id] = @distributor.id
    ret[:seller_id] = @seller.id

    ret
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
    ret['amount_allocated'] = campaign.amount_allocated
    ret['last_contribution'] = campaign.last_contribution
    ret['seller_id'] = campaign.seller.seller_id
    ret['seller_distributor_pairs'] = campaign.seller_distributor_pairs
    ret
  end

  def valid_campaigns
    Campaign.where(valid: true)
  end
end
