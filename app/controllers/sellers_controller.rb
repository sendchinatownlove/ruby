# frozen_string_literal: true

class SellersController < ApplicationController
  before_action :set_seller, only: %i[show update]

  # GET /sellers
  def index
    response.headers.delete 'X-Frame-Options'
    query = Validate::GetSellersQuery.new(params)

    raise InvalidParameterError, query.errors.full_messages.to_sentence unless query.valid?

    Rails.cache.fetch('sellers', expires_in: 60.minutes) do
      @sellers = Seller.order("#{query.sort_key} #{query.sort_order}")
      if stale?(@seller)
        sellers = @sellers.map do |seller|
          SellersHelper.generate_seller_json(
            seller: seller
          )
        end
        json_response(sellers)
      end
    end
  end

  # GET /sellers/total_contributions
  def get_contributions
    @sellers = Seller.all
    totals = {
      donation_amount: 0,
      gift_card_amount: 0,
      gift_a_meal_amount: 0
    }

    @sellers.each do |seller|
      seller_contributions = SellersHelper.collect_contribution_amounts(seller)

      totals[:donation_amount] += seller_contributions[:donation_amount]
      totals[:gift_card_amount] += seller_contributions[:gift_card_amount]
      totals[:gift_a_meal_amount] += seller_contributions[:gift_a_meal_amount]

    end
    json_response(totals)
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
      :cost_per_meal,
      :business_type,
      :num_employees,
      :founded_year,
      :website_url,
      :menu_url,
      :target_amount,
      :square_location_id,
      :non_profit_location_id,
      :logo_image_url,
      gallery_image_urls: []
    )
  end

  def set_seller
    @seller = Seller.find_by!(seller_id: params[:id])
  end
end
