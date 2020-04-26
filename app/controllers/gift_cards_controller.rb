# frozen_string_literal: true

require 'stripe'

class GiftCardsController < ApplicationController
  before_action :set_gift_card, only: %i[show update destroy]

  # GET /gift_cards/:id
  def show
    item = Item.find_by(gift_card_detail_id: @gift_card_detail[:id])
    json_response(item)
  end

  # PUT /gift_cards/:id
  def update
    # only allows updating amounts of gift cards
    original_amount = @gift_card.amount
    new_amount = update_params[:amount].to_i

    if original_amount < new_amount
      raise InvalidGiftCardUpdate, 'Cannot increase gift card amount'
    end

    @gift_card.update!(update_params)
    head :no_content
  end

  private

  def update_params
    params.require(:amount)
    params.permit(:amount)
  end

  def set_gift_card
    params.require(:id)
    @gift_card_detail = GiftCardDetail.find_by(gift_card_id: params[:id])
  end

  def stripe_charge
    Stripe.api_key = 'sk_test_Vux9P2VnjEDHuR4Cg8DHWmhq00y6iKGY8x'
    Stripe::Checkout::Session.retrieve(params[:charge_id])
  end
end
