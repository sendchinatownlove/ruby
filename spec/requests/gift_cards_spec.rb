require 'rails_helper'

RSpec.describe 'Gift Cards API', type: :request do

  # Test suite for POST /giftcards
  describe 'POST /giftcards' do
    # valid payload
    let(:valid_attributes) { { merchant_id: 'shunfa-bakery', amount: '5000', item: 'GIFT-CARD' } }

    context 'when the request is valid' do
      before { post '/gift_cards', params: valid_attributes }

      it 'returns valid response' do
        expect(json).not_to be_empty
        expect(json['message']).to eq('hello world!')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end
end
