require 'rails_helper'

RSpec.describe 'Charges API', type: :request do

  # Test suite for POST /charges
  describe 'POST /charges' do
    # valid payload
    let(:valid_attributes) { { merchant_id: 'shunfa-bakery', amount: '5000', item: 'GIFT-CARD' } }

    context 'when the request is valid' do
      before { post '/charges', params: valid_attributes }

      it 'returns stripe charges session id' do
        expect(json).not_to be_empty
        expect(json['display_items'].first['custom']['description']).to eq('$50.00 Gift Card for shunfa-bakery')
        expect(json['success_url']).to eq('https://sendchinatownlove.com/charge-sucessful')
        expect(json['cancel_url']).to eq('https://sendchinatownlove.com/charge-canceled')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end
end
