# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChargesController, type: :controller do
  include MockApiResponseHelper

  describe "POST create" do
    let!(:mock_response) { MockApiResponseHelper::MockSquareApiResponse.new }
    let!(:seller) { create :seller, :with_distributor, square_location_id: "1234", seller_id: 42 }
    let!(:seller_non_prof) { create :seller, :with_distributor, non_profit_location_id: "4321", seller_id: 43 }

    context "when seller has a non_profit_location_id" do
      it "should create a payment_intent using the non_profit_location_id" do
        allow(SquareManager::PaymentCreator)
                                            .to receive(:call)
                                            .with(payment_create_params(seller_non_prof, non_profit = true))
                                            .and_return(mock_response)

        response = post :create, params: charge_params(seller_non_prof, is_square = true), as: :json
        expect(response.status).to eq 200
        expect(PaymentIntent.find_by square_location_id: seller_non_prof.non_profit_location_id).not_to eq nil
      end

    end

    context "when seller has a blank non_profit_location_id" do
      it "should create a payment_intent using the square_location_id" do
        allow(SquareManager::PaymentCreator)
                                            .to receive(:call)
                                            .with(payment_create_params(seller, non_profit = false))
                                            .and_return(mock_response)

        response = post :create, params: charge_params(seller, is_square = true), as: :json
        expect(response.status).to eq 200
        expect(PaymentIntent.find_by square_location_id: seller.square_location_id).not_to eq nil
      end
    end
  end

  ###############
  ### Helpers ###
  ###############
  def charge_params(seller, is_square = false)
    params = {
      seller_id: seller.seller_id,
      line_items: line_items,
      email: "cthulhu@rlyeh.com",
      is_square: is_square,
      name: "Cthulhu",
      idempotency_key: "42",
      is_subscribed: true,
      is_distribution: true,
    }

    params.merge! nonce: 'cnon:card-nonce-ok' if is_square
    params
  end

  def line_items
    [{ 
      'amount' => 50, 
      'currency' => "usd", 
      'quantity' => 1, 
      'item_type' => "donation",
     }]
  end

  def payment_create_params(seller, non_profit)
    cparams = charge_params(seller, is_square = true)
    lid = non_profit ? seller.non_profit_location_id : seller.square_location_id

    {
      nonce: cparams[:nonce],
      amount: line_items.first['amount'],
      email: cparams[:email],
      location_id: lid,
    }
  end
end
