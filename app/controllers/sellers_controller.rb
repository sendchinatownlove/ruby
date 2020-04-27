# frozen_string_literal: true

class SellersController < ApplicationController
  before_action :set_seller, only: %i[show update]

  # GET /sellers
  def index
    @sellers = Seller.all
    sellers = @sellers.map do |seller|
      SellersHelper.generate_seller_json(
        seller: seller
      )
    end
    json_response(sellers)
  end

  # POST /sellers
  def create
    @seller = Seller.create!(seller_params)
    seller = SellersHelper.generate_seller_json(seller: @seller)
    json_response(seller, :created)
  end

  # GET /sellers/:seller_id
  def show
    seller = SellersHelper.generate_seller_json(seller: @seller)
    json_response(seller)
  end

  # PUT /sellers/:seller_id
  def update
    @seller.update(update_params)
    @seller.save
    seller = SellersHelper.generate_seller_json(seller: @seller)
    json_response(seller)
  end

  private

  def seller_params
    params.required(:seller_id)
    params.required(:square_location_id)
    update_params
  end

  def update_params
    params.permit(
      :seller_id,
      :cuisine_name,
      :name,
      :story,
      :summary,
      :owner_name,
      :owner_image_url,
      :accept_donations,
      :sell_gift_cards,
      :hero_image_url,
      :progress_bar_color,
      :business_type,
      :num_employees,
      :founded_year,
      :website_url,
      :menu_url,
      :target_amount,
      :square_location_id
    )
  end

  def set_seller
    @seller = Seller.find_by!(seller_id: params[:id])
  end
end
