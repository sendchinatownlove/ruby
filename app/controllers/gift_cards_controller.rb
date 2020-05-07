# frozen_string_literal: true

require 'stripe'

class GiftCardsController < ApplicationController
  before_action :set_gift_card, only: %i[show update destroy]

  # GET /gift_cards/:id
  def show
    item = Item.find_by(gift_card_detail_id: @gift_card_detail[:id])
    #need to get the gift_card_detail of item and feed its ID into gift card recent
    SellersHelper.gift_card_recent()

    current_amount = json_response(item)

    #look at the models
    #schema file
    #items, giftcard_detail, giftcard -> schema.rb

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
