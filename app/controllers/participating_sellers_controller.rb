# frozen_string_literal: true

class ParticipatingSellersController < ApplicationController
  before_action :set_participating_seller, only: %i[show update]

  def index
    json_response(ParticipatingSeller.all)
  end

  # POST /participating_sellers
  def create
    json_response(ParticipatingSeller.create!(participating_seller_params), :created)
  end

  # GET /participating_sellers/:id
  def show
    json_response(@participating_seller)
  end

  # PUT /participating_sellers/:id
  def update
    @participating_seller.update(participating_seller_params)
    json_response(@participating_seller)
  end

  private

  def participating_seller_params
    params.permit(
      :name,
      :seller_id,
      :stamp_url
    )
  end

  def set_participating_seller
    @participating_seller = ParticipatingSeller.find(params[:id])
  end

  def participating_seller_json
    # Do not return the tickets_secret
    json = participating_seller.as_json.except('tickets_secret')
  end
end
