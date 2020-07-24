# frozen_string_literal: true

class CampaignsController < ApplicationController
  before_action :set_campaign, only: %i[show update]

  # GET /campaigns
  def index
    json_response(Campaign.all)
  end

  # GET /campaigns/:id
  def show
    json_response(@campaign)
  end
  
  # POST /campaigns
  def create
    campaign = Campaign.create!(create_params)
    json_response(campaign, :created)
  end

  # PUT /campaigns/:id
  def update
    @campaign.update(update_params)
    json_response(@campaign)
  end

  private

  def create_params
    params.require(:end_date)
    params.require(:location_id)
    params.require(:seller_id)

    ret = params.permit(
      :active,
      :description,
      :end_date,
      :valid,
      gallery_image_urls: []
    )

    set_location
    set_seller
    ret[:location_id] = @location.id
    ret[:seller_id] = @seller.id

    ret
  end

  def update_params
    params.permit(
      :active,
      :description,
      :valid,
      gallery_image_urls: [],
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
end

