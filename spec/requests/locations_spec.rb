# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Locations API' do
  # Initialize the test data
  let!(:locations) { create_list(:location, 20) }
  let(:id) { locations.first.id }

  # Test suite for GET /sellers/:seller_id/locations
  describe 'GET /locations' do
    before { get "/locations" }

    context 'when seller exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all seller locations' do
        expect(json.size).to eq(20)
      end
    end
  end

  # Test suite for GET /locations/:id
  describe 'GET /locations/:id' do
    before { get "/locations/#{id}" }

    context 'when location exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the location' do
        expect(json['id']).to eq(id)
      end
    end

    context 'when location does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Location/)
      end
    end
  end

  # Test suite for POST /locations
  describe 'POST /locations' do
    let(:valid_attributes) do
      {
        address1: '123 Justin Way',
        city: 'Narnia',
        state: 'NY',
        zip_code: '12345',
        phone_number: '(281) 330-8004'
      }
    end

    context 'when request attributes are valid' do
      before do
        post(
          "/locations",
          params: valid_attributes,
          as: :json
        )
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when an invalid request' do
      before { post "/locations", params: {} }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to match(
          /param is missing or the value is empty: address1/
        )
      end
    end
  end

  # Test suite for PUT /locations/:id
  describe 'PUT /locations/:id' do
    let(:valid_attributes) { { address1: '123 Mozart' } }

    before do
      put(
        "/locations/#{id}",
        params: valid_attributes,
        as: :json
      )
    end

    context 'when location exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'updates the location' do
        updated_address = Location.find(id)
        expect(updated_address.address1).to match(/123 Mozart/)
      end
    end

    context 'when the location does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Location/)
      end
    end
  end
end
