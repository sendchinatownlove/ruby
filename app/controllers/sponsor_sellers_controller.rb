# frozen_string_literal: true

class SponsorSellersController < ApplicationController
  before_action :set_sponsor_seller, only: %i[show update]

  def index
    json_response(SponsorSeller.all)
  end

  # POST /sponsor_sellers
  def create
    json_response(SponsorSeller.create!(sponsor_seller_params), :created)
  end

  # GET /sponsor_sellers/:id
  def show
    json_response(@sponsor_seller)
  end

  # PUT /sponsor_sellers/:id
  def update
    @sponsor_seller.update(sponsor_seller_params)
    json_response(@sponsor_seller)
  end

  private

  def sponsor_seller_params
    params.permit(
      :name,
      :location_id,
      :logo_url,
      :reward,
      :reward_cost,
      :reward_detail
    )
  end

  def set_sponsor_seller
    @sponsor_seller = SponsorSeller.find(params[:id])
  end
end
