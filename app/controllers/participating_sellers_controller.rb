# frozen_string_literal: true

class ParticipatingSellersController < ApplicationController
  before_action :set_participating_seller, only: %i[show update]

  def index
    @participating_sellers = ParticipatingSeller.where(active: true)
    json_response(participating_sellers_json)
  end

  # POST /participating_sellers
  def create
    @participating_seller = ParticipatingSeller.create!(participating_seller_params)
    json_response(participating_seller_json, :created)
  end

  # GET /participating_sellers/:id
  def show
    json_response(participating_seller_json)
  end

  # PUT /participating_sellers/:id
  def update
    @participating_seller.update(participating_seller_params)
    json_response(participating_seller_json)
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

  def participating_seller_json(participating_seller: @participating_seller)
    # Do not return the tickets_secret
    json = participating_seller.as_json.except('tickets_secret')
    json
  end

  def participating_sellers_json
    @participating_sellers.map { |s| participating_seller_json participating_seller: s }
  end
end
