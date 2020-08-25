# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpenHours', type: :request do
  # Initialize the test data
  before { freeze_time }
  let(:current_time) { Time.current.utc.iso8601(3).to_s }
  let!(:seller) { create(:seller) }
  let(:seller_id) { seller.seller_id }
  let!(:open_hours) { create_list(:open_hour, 7, seller_id: seller.id) }
  let(:id) { open_hours.first.id }

  # Test suite for GET /sellers/:seller_id/open_hours
  describe 'GET /sellers/:seller_id/open_hour' do
    before { get "/sellers/#{seller_id}/open_hour" }

    context 'when seller exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all seller open_hours' do
        expect(json.size).to eq(7)
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

  # Test suite for POST /sellers/:seller_id/open_hour
  describe 'POST /sellers/:seller_id/open_hour' do
    let(:valid_attributes) do
      {
        open_day: 'MON',
        close_day: 'MON',
        open_time: Time.find_zone('UTC').parse('6:30'),
        close_time: Time.find_zone('UTC').parse('18:30')
      }
    end

    let(:invalid_attributes) do
      {
        invalid: 'yellow'
      }
    end

    let(:opens_after_closes_attributes) do
      {
        open_day: 'MON',
        close_day: 'MON',
        open_time: Time.find_zone('UTC').parse('18:30'),
        close_time: Time.find_zone('UTC').parse('6:30')
      }
    end

    context 'when request attributes are valid' do
      before do
        post(
          "/sellers/#{seller_id}/open_hour",
          params: valid_attributes,
          as: :json
        )
      end

      it 'creates an open_hour' do
        actual_json = json.except('id')
        expected_json = valid_attributes.except('id')
        expected_json['created_at'] = current_time
        expected_json['updated_at'] = current_time
        expected_json['open_day'] = 'MON'
        expected_json['close_day'] = 'MON'
        # workaround since the db modifies the date and messes up the rspec validation
        expect(actual_json['open_time'].to_time.strftime('%I:%M%p')).to eq('06:30AM')
        expect(actual_json['close_time'].to_time.strftime('%I:%M%p')).to eq('06:30PM')
        expected_json['open_time'] = actual_json['open_time']
        expected_json['close_time'] = actual_json['close_time']
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
          "/sellers/#{seller_id}/open_hour",
          params: invalid_attributes,
          as: :json
        )
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when attempting to create an open hour that closes before it opens' do
      before do
        post(
          "/sellers/#{seller_id}/open_hour",
          params: opens_after_closes_attributes,
          as: :json
        )
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  # Test suite for PUT /sellers/:seller_id/open_hour/:id
  describe 'PUT /sellers/:seller_id/open_hour/:id' do
    let(:valid_attributes) { { close_day: 'TUE' } }

    before do
      put(
        "/sellers/#{seller_id}/open_hour/#{id}",
        params: valid_attributes,
        as: :json
      )
    end

    context 'when open_hour exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'updates the menu_item' do
        updated_open_hour = OpenHour.find(id)
        expect(updated_open_hour.close_day).to match(/TUE/)
      end
    end

    context 'when the open_hour does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find OpenHour/)
      end
    end
  end

  # Test suite for DELETE /sellers/:seller_id/open_hour/:id
  describe 'DELETE /sellers/:seller_id/open_hour/:id' do
    let(:valid_attributes) { { open_day: 'MON' } }

    before do
      delete(
        "/sellers/#{seller_id}/open_hour/#{id}",
        params: valid_attributes,
        as: :json
      )
    end

    context 'when open_hour exists' do
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'confirms deletion of the open_hour' do
        expect { OpenHour.find(id) }.to raise_exception(
          ActiveRecord::RecordNotFound
        )
      end
    end
  end
end
