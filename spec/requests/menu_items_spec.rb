# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MenuItems API' do
  # Initialize the test data
  before { freeze_time }
  let(:current_time) { Time.current.utc.iso8601(3).to_s }
  let!(:seller) { create(:seller) }
  let(:seller_id) { seller.seller_id }
  let!(:menu_items) { create_list(:menu_item, 20, seller_id: seller.id) }
  let(:id) { menu_items.first.id }

  # Test suite for GET /sellers/:seller_id/menu_items
  describe 'GET /sellers/:seller_id/menu_items' do
    before { get "/sellers/#{seller_id}/menu_items" }

    context 'when seller exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all seller menu_items' do
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

  # Test suite for POST /sellers/:seller_id/menu_items
  describe 'POST /sellers/:seller_id/menu_items' do
    let(:valid_attributes) do
      {
        name: 'Food',
        description: 'Awesome Food',
        amount: 15.5,
        image_url: 'image.com'
      }
    end

    let(:invalid_attributes) do
      {
        invalid: 'Food'
      }
    end

    context 'when request attributes are valid' do
      before do
        post(
          "/sellers/#{seller_id}/menu_items",
          params: valid_attributes,
          as: :json
        )
      end

      it 'creates a menu_item' do
        actual_json = json.except('id')
        expected_json = valid_attributes.except('id')
        expected_json['created_at'] = current_time
        expected_json['updated_at'] = current_time
        expected_json['name'] = 'Food'
        expected_json['description'] = 'Awesome Food'
        expected_json['amount'] = '15.5'
        expected_json['image_url'] = 'image.com'
        expected_json['seller_id'] = seller.id
        expect(actual_json).to eq(expected_json.with_indifferent_access)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when request attributes are invalid' do
      before do
        post(
          "/sellers/#{seller_id}/menu_items",
          params: invalid_attributes,
          as: :json
        )
      end

      it 'creates a menu_item' do
        actual_json = json.except('id')
        expected_json = valid_attributes.except('id')
        expected_json['created_at'] = current_time
        expected_json['updated_at'] = current_time
        expected_json['name'] = nil
        expected_json['description'] = nil
        expected_json['amount'] = nil
        expected_json['image_url'] = nil
        expected_json['seller_id'] = seller.id
        expect(actual_json).to eq(expected_json.with_indifferent_access)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end
  end

  # Test suite for PUT /sellers/:seller_id/menu_items/:id
  describe 'PUT /sellers/:seller_id/menu_items/:id' do
    let(:valid_attributes) { { name: 'AwesomeFood' } }

    before do
      put(
        "/sellers/#{seller_id}/menu_items/#{id}",
        params: valid_attributes,
        as: :json
      )
    end

    context 'when menu_item exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'updates the menu_item' do
        updated_menu_item = MenuItem.find(id)
        expect(updated_menu_item.name).to match(/AwesomeFood/)
      end
    end

    context 'when the menu_item does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find MenuItem/)
      end
    end
  end

  # Test suite for DELETE /sellers/:seller_id/menu_items/:id
  describe 'DELETE /sellers/:seller_id/menu_items/:id' do
    let(:valid_attributes) { { name: 'AwesomeFood' } }

    before do
      delete(
        "/sellers/#{seller_id}/menu_items/#{id}",
        params: valid_attributes,
        as: :json
      )
    end

    context 'when menu_item exists' do
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'confirms deletion of the menu_item' do
        expect { MenuItem.find(id) }.to raise_exception(
          ActiveRecord::RecordNotFound
        )
      end
    end
  end
end
