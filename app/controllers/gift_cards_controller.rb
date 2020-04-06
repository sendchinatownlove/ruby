require 'stripe'

class GiftCardsController < ApplicationController
  before_action :set_gift_card, only: [:show, :update, :destroy]

  # POST /gift_cards
  def create
    @gift_card = GiftCard.create!(create_params)
    json_response(@gift_card, :created)
  end

  # GET /gift_cards/:d
  def show
    json_response(@gift_card)
  end

  # PUT /gift_cards/:id
  def update
    # only allows updating amounts of gift cards
    original_amount = @gift_card.amount
    new_amount = update_params[:amount].to_i

    if original_amount < new_amount
      raise InvalidGiftCardUpdate.new 'Cannot increase gift card amount'
    end

    @gift_card.update!(update_params)
    head :no_content
  end

  private

  def create_params
    params.require(:charge_id)
    charge = stripe_charge
    {
        charge_id: params[:charge_id],
        merchant_id: charge[:metadata][:merchant_id],
        customer_id: charge[:customer],
        amount: charge[:display_items].first[:amount]
    }
  end

  def update_params
    params.require(:amount)
    params.permit(:amount)
  end

  def set_gift_card
    @gift_card = GiftCard.find(params[:id])
  end

  def stripe_charge
    Stripe.api_key = 'sk_test_Vux9P2VnjEDHuR4Cg8DHWmhq00y6iKGY8x'
    Stripe::Checkout::Session.retrieve(params[:charge_id])
  end
end
