# frozen_string_literal: true

class GiftCardsController < ApplicationController
  before_action :set_gift_card, only: %i[show]

  # GET /gift_cards/:id
  def show
    item = Item.find_by(id: @gift_card_detail.item_id).as_json
    item['gift_card_detail'] = @gift_card_detail.as_json
    item['gift_card_detail']['amount'] = @gift_card_detail.amount
    json_response(item)
  end

  private

  def set_gift_card
    params.require(:id)
    @gift_card_detail = GiftCardDetail.find_by!(gift_card_id: params[:id])
  end
end
