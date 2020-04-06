class SellersController < ApplicationController
  before_action :set_seller, only: [:show, :update]

  # GET /sellers
  def index
    @sellers = Seller.all
    json_response(@sellers)
  end

  # POST /sellers
  def create
    @seller = Seller.create!(seller_params)
    json_response(@seller, :created)
  end

  # GET /sellers/:url
  def show
    json_response(@seller)
  end

  # PUT /sellers/:url
  def update
    @seller.update(seller_params)
    json_response(@seller)
  end

  private

  def seller_params
    # whitelist params
    params.required(:url)
    params.permit(
      :url,
      :cuisine_name,
      :merchant_name,
      :story,
      :owner_name,
      :owner_image_url,
      :accept_donations,
      :sell_gift_cards
    )
  end

  def set_seller
    @seller = Seller.find_by!(url: params[:id])
  end
end
