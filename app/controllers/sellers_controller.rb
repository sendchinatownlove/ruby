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

  # GET /sellers/:seller_id
  def show
    json_response(@seller)
  end

  # PUT /sellers/:seller_id
  def update
    @seller.update(seller_params)
    json_response(@seller)
  end

  private

  def seller_params
    # whitelist params
    params.required(:seller_id)
    params.permit(
      :seller_id,
      :cuisine_name,
      :name,
      :story,
      :owner_name,
      :owner_image_url,
      :accept_donations,
      :sell_gift_cards
    )
  end

  def set_seller
    @seller = Seller.find_by!(seller_id: params[:id])
  end
end
