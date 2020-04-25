# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Gift Cards API', type: :request do
  # initialize test data
  let!(:gift_card) { create(:gift_card_detail) }
  let!(:gift_card) { create(:item) }
  let(:gift_card_id) { gift_card.id }

  skip 'POST /gift_cards' do
    let(:attributes) { { charge_id: 'charge-1' } }
    let(:charge) do
      {
        id: 'charge-1',
        display_items: [{ amount: 5000 }],
        customer: 'customer-1',
        metadata: { merchant_id: 'shunfa-bakery' }
      }
    end

    before do
      allow(Stripe::Checkout::Session).to receive(:retrieve).and_return(charge)
      post '/gift_cards', params: attributes
    end

    it 'returns valid response' do
      p json
      expect(json).not_to be_empty
      expect(json['merchant_id']).to eq('shunfa-bakery')
      expect(json['charge_id']).to eq('charge-1')
      expect(json['customer_id']).to eq('customer-1')
      expect(json['amount']).to eq(5000)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(201)
    end
  end

  skip 'GET /gift_cards/:id' do
    before { get "/gift_cards/#{gift_card_id}" }

    context 'when gift card exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the gift card' do
        expect(json['id']).to eq(gift_card_id)
      end
    end

    context 'when gift card does not exist' do
      let(:gift_card_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find GiftCard/)
      end
    end
  end

  skip 'PUT /gift_cards/:id' do
    before { put "/gift_cards/#{gift_card_id}", params: attributes }

    context 'when amount is valid' do
      let(:attributes) { { amount: gift_card.amount - 500 } }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when amount is negative' do
      let(:attributes) { { amount: -100 } }

      it 'updates the record' do
        expect(response.body).to match(/Amount must be greater than or equal to 0/)
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when the amount is greater than original' do
      let(:attributes) { { amount: gift_card.amount + 500 } }

      it 'updates the record' do
        expect(response.body).to match(/Cannot increase gift card amount/)
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(422)
      end
    end
  end
end
