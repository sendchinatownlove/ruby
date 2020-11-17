# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DeliveryOptions', type: :request do
  # Initialize the test data
  before { freeze_time }
  let(:current_time) { Time.current.utc.iso8601(3).to_s }
  let!(:seller) { create(:seller) }
  let(:seller_id) { seller.seller_id }
  let(:delivery_type) { create(:delivery_type) }
  let(:delivery_type_id) { delivery_type.id }
  let!(:delivery_options) { create_list(:delivery_option, 20, delivery_type_id: delivery_type_id, seller_id: seller.id) }
  let(:id) { delivery_options.first.id }

  # Test suite for GET /sellers/:seller_id/delivery_options
  describe 'GET /sellers/:seller_id/delivery_options' do
    before { get "/sellers/#{seller_id}/delivery_options" }

    context 'when seller exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all seller delivery_options' do
        expect(json.size).to eq(20)
        expect(json[0]['delivery_type']['name']).not_to be_nil
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

  # Test suite for POST /sellers/:seller_id/menu_items
  describe 'POST /sellers/:seller_id/delivery_options' do
    let(:valid_attributes) do
      {
        url: 'www.grubhub.com',
        delivery_type_id: delivery_type_id
      }
    end

    let(:invalid_attributes) do
      {
        invalid: 'quick brown fox'
      }
    end

    context 'when request attributes are valid' do
      before { post "/sellers/#{seller_id}/delivery_options", params: valid_attributes, as: :json }

      it 'creates a delivery_option' do
        actual_json = json.except('id')
        expected_json = valid_attributes.except('id')
        expected_json['created_at'] = current_time
        expected_json['updated_at'] = current_time
        expected_json['url'] = 'www.grubhub.com'
        expected_json['phone_number'] = nil
        expected_json['seller_id'] = seller.id
        expected_json['delivery_type_id'] = delivery_type_id
        expect(actual_json).to eq(expected_json.with_indifferent_access)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when request attributes are invalid' do
      before { post "/sellers/#{seller_id}/delivery_options", params: invalid_attributes, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  # Test suite for PUT /sellers/:seller_id/delivery_options/:id
  describe 'PUT /sellers/:seller_id/delivery_options/:id' do
    let(:valid_attributes) { { url: 'www.givemefood.com' } }

    before { put "/sellers/#{seller_id}/delivery_options/#{id}", params: valid_attributes, as: :json }
    context 'when delivery_option exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'updates the delivery_option' do
        updated_delivery_options = DeliveryOption.find(id)
        expect(updated_delivery_options.url).to match(/www.givemefood.com/)
      end
    end

    context 'when the delivery_option does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find DeliveryOption/)
      end
    end
  end

  # Test suite for DELETE /sellers/:seller_id/delivery_options/:id
  describe 'DELETE /sellers/:seller_id/delivery_options/:id' do
    let(:valid_attributes) { { url: 'www.hungryhungryhungry.com' } }

    before { delete "/sellers/#{seller_id}/delivery_options/#{id}", params: valid_attributes, as: :json }

    context 'when delivery_option exists' do
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'confirms deletion of the delivery_option' do
        expect { updated_delivery_options = DeliveryOption.find(id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
end
