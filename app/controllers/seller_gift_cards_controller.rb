# frozen_string_literal: true

class SellerGiftCardsController < ApplicationController
  before_action :set_seller

  # GET /sellers/:seller_id/gift_cards/:id
  def show
    query = GiftCardDetail
            .select(
              :seller_gift_card_id,
              :value,
              :name,
              :email,
              :created_at,
              :expiration
            )
            .joins(:item, :recipient)
            .where(
              items: {
                seller_id: @seller.id,
                refunded: false
              }
            )
            .joins(
              "join (#{GiftCardAmount.latest_amounts_sql}) as la on la.gift_card_detail_id = gift_card_details.id"
            )
    query = query.where(single_use: false) if params.key?('filterGAM')
    query = query.to_sql

    # processing in one query to get a PG::Result, instead multiple queries when building html
    result = GiftCardDetail.connection.select_all(query)
    json_response(result)
  end

  private

  def set_seller
    @seller = Seller.find_by!(seller_id: params[:seller_id])

    if @seller.gift_cards_access_token != params[:id]
      raise ActiveRecord::RecordNotFound
    end
  end
end
