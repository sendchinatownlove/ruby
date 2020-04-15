require 'rails_helper'

RSpec.describe 'Addresses API' do
  # Initialize the test data
  let!(:seller) { create(:seller) }
  let!(:addresses) { create_list(:address, 20, seller_id: seller.id) }
  let(:seller_id) { seller.seller_id }
  let(:id) { addresses.first.id }

  # Test suite for GET /sellers/:seller_id/addresses
  describe 'GET /sellers/:seller_id/addresses' do
    before { get "/sellers/#{seller_id}/addresses" }

    context 'when seller exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all seller addresses' do
        expect(json.size).to eq(20)
      end
    end

    context 'when seller does not exist' do
      let(:seller_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Seller/)
      end
    end
  end

  # Test suite for GET /sellers/:seller_id/addresses/:id
  describe 'GET /sellers/:seller_id/addresses/:id' do
    before { get "/sellers/#{seller_id}/addresses/#{id}" }

    context 'when seller address exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the address' do
        expect(json['id']).to eq(id)
      end
    end

    context 'when seller address does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Address/)
      end
    end
  end

  # Test suite for PUT /sellers/:seller_id/addresses
  describe 'POST /sellers/:seller_id/addresses' do
    let(:valid_attributes) do
      {
        address1: '123 Justin Way',
        city: 'Narnia',
        state: 'NY',
        zip_code: '12345'
      }
    end

    context 'when request attributes are valid' do
      before { post "/sellers/#{seller_id}/addresses", params: valid_attributes, as: :json }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when an invalid request' do
      before { post "/sellers/#{seller_id}/addresses", params: {} }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to match(/param is missing or the value is empty: address1/)
      end
    end
  end

  # Test suite for PUT /sellers/:seller_id/addresses/:id
  describe 'PUT /sellers/:seller_id/addresses/:id' do
    let(:valid_attributes) { { address1: '123 Mozart' } }

    before { put "/sellers/#{seller_id}/addresses/#{id}", params: valid_attributes, as: :json }

    context 'when address exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'updates the address' do
        updated_address = Address.find(id)
        expect(updated_address.address1).to match(/123 Mozart/)
      end
    end

    context 'when the address does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Address/)
      end
    end
  end
end
