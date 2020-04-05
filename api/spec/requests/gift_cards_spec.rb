require 'rails_helper'

RSpec.describe 'Gift Cards API', type: :request do

  # Test suite for POST /giftcards
  describe 'POST /giftcards' do
    # valid payload
    let(:valid_attributes) { { merchant_id: 'shunfa-bakery', amount: 5000, charge_id: 'charge-1' } }

    context 'when the request is valid' do
      before { post '/gift_cards', params: valid_attributes }

      it 'returns valid response' do
        expect(json).not_to be_empty
        expect(json['merchant_id']).to eq('shunfa-bakery')
        expect(json['charge_id']).to eq('charge-1')
        expect(json['amount']).to eq(5000)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(201)
      end
    end
  end
end
