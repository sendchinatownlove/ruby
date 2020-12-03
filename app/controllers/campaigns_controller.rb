# frozen_string_literal: true
include Pagy::Backend

class CampaignsController < ApplicationController
  before_action :set_campaign, only: %i[show update]
  after_action { pagy_headers_merge(@pagy) if @pagy }

  # GET /campaigns
  def index
    # @NOTE(wilson) check to see if querying for inactive campaigns
    # otherwise return active campaigns by default
    inactive = params[:inactive]
    if inactive == 'true'
      @campaigns = past_campaigns.order('end_date desc').all

      @pagy, @records = pagy(@campaigns)
      json_response(campaigns_records_json)
    else
      @campaigns = valid_campaigns.order(:end_date).all

      @pagy, @records = pagy(@campaigns)
      json_response(campaigns_records_json)
    end
  end

  # GET /campaigns/:id
  def show
    json_response(campaign_json)
  end

  # POST /campaigns
  def create
    @campaign = Campaign.create!(create_params)
    unless @seller.present? ^ @project.present?
      raise InvalidLineItem, "Project or Seller must exist, but not both. seller id: #{seller_id}, project_id: #{project_id}"
    end

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
    params.require(:distributor_id)

    ret = params.permit(
      :active,
      :description,
      :end_date,
      :price_per_meal,
      :target_amount,
      :nonprofit_id,
      :seller_id,
      :project_id,
      gallery_image_urls: []
    )

    set_location
    set_seller
    set_project
    set_distributor

    ret[:location_id] = @location.id
    ret[:seller_id] = @seller.id if @seller.present?
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
      :seller_id
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
    @seller = Seller.find_by(seller_id: params[:seller_id])
  end

  def set_project
    @project = Project.find_by(id: params[:project_id])
  end

  def set_distributor
    @distributor = Distributor.find(params[:distributor_id])
  end

  def campaigns_json
    @campaigns.map { |c| campaign_json campaign: c }
  end

  def campaigns_records_json(record: @records)
    record.map { |c| campaign_json campaign: c }
  end

  def campaign_json(campaign: @campaign)
    ret = campaign.as_json
    ret['amount_raised'] = campaign.amount_raised
    ret['amount_allocated'] = campaign.amount_allocated
    ret['display_name'] = campaign.display_name
    ret['last_contribution'] = campaign.last_contribution
    ret['seller_distributor_pairs'] = campaign.seller_distributor_pairs
    ret
  end

  def valid_campaigns
    Campaign.where(valid: true)
  end

  def past_campaigns
    Campaign.where(valid: true, active: false)
  end
end
