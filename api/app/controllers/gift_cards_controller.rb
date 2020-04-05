class GiftCardsController < ApplicationController
  before_action :set_gift_card, only: [:show, :update, :destroy]

  # POST /gift_cards
  def create
    @gift_card = GiftCard.create!(gift_card_params)

    json_response(@gift_card, :created)
  end

  # GET /gift_cards/:d
  def show
    json_response(@gift_card)
  end

  # PUT /gift_cards/:id
  def update
    # TODO: should only be able to update amount
    @gift_card.update(gift_card_params)
    head :no_content
  end

  def destroy
    @gift_card.destroy
    head :no_content
  end

  private

  def gift_card_params
    # TODO: get merchant_id and amount by looking up the charge from Stripe
    params.require(:charge_id)
    params.permit(:merchant_id, :charge_id, :amount)
  end

  def set_gift_card
    @gift_card = GiftCard.find(params[:id])
  end
end
