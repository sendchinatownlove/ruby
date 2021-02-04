# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Distributors', type: :request do
  describe 'GET /distributors' do
    let!(:distributors) do
      (1..10).map { create :distributor }
    end

    before { get '/distributors' }

    it 'returns the distributor' do
      expect(json.size).to eq distributors.size
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /distributors/:id' do
    let!(:distributor) { create :distributor }
    before { get "/distributors/#{distributor_id}" }

    context 'with valid distributor_id' do
      let(:distributor_id) { distributor.id }

      it 'returns the distributor' do
        expect(json['id']).to eq distributor.id
        expect(json['image_url']).to eq distributor.image_url
        expect(json['website_url']).to eq distributor.website_url
        expect(json['contact_id']).to eq distributor.contact_id
        expect(json['name']).to eq distributor.name
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid distributor_id' do
      let(:distributor_id) { 'rrarararararararr' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Distributor/)
      end
    end
  end

  describe 'POST /distributors' do
    let!(:contact) { create :contact }
    before do
      post(
        '/distributors',
        params: attrs,
        as: :json
      )
    end

    context 'with valid attrs' do
      let(:attrs) do
        {
          contact_id: contact.id,
          website_url: 'sendchinatownlove.com',
          image_url: 'sendchinatownlove.com/lalalllala',
          name: 'Send Chinatown Love'
        }
      end

      it 'creates the distributor' do
        expect(json['image_url']).to eq attrs[:image_url]
        expect(json['website_url']).to eq attrs[:website_url]
        expect(json['contact_id']).to eq attrs[:contact_id]
        expect(json['name']).to eq attrs[:name]
        expect(json['id']).not_to be_nil

        distributor = Distributor.find_by(contact_id: attrs[:contact_id])
        expect(distributor).not_to be_nil
        expect(distributor.image_url).to eq attrs[:image_url]
        expect(distributor.website_url).to eq attrs[:website_url]
        expect(distributor.contact_id).to eq attrs[:contact_id]
        expect(distributor.name).to eq attrs[:name]
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid attrs' do
      let(:attrs) do
        { image_url: 'rrarararararararr' }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a missing param message' do
        expect(response.body).to match(/param is missing or the value is empty: contact_id/)
      end
    end
  end

  describe 'PUT /distributors/:id' do
    let!(:distributor) { create :distributor }
    let!(:contact) { create :contact }
    before do
      put(
        "/distributors/#{distributor_id}",
        params: attrs,
        as: :json
      )
    end

    context 'with valid attrs' do
      let(:distributor_id) { distributor.id }
      let(:attrs) do
        {
          website_url: 'sendchinatownlove.com',
          image_url: 'sendchinatownlove.com/lalalllala',
          name: 'Send Chinatown Love',
          contact_id: contact.id
        }
      end

      it 'updates the distributor' do
        distributor = Distributor.find_by(contact_id: attrs[:contact_id])
        expect(distributor).not_to be_nil
        expect(distributor.image_url).to eq attrs[:image_url]
        expect(distributor.website_url).to eq attrs[:website_url]
        expect(distributor.contact_id).to eq attrs[:contact_id]
        expect(distributor.name).to eq attrs[:name]
      end

      it 'returns the updated distributor' do
        distributor = Distributor.find_by(contact_id: attrs[:contact_id])
        expect(json['image_url']).to eq attrs[:image_url]
        expect(json['website_url']).to eq attrs[:website_url]
        expect(json['name']).to eq attrs[:name]
        expect(json['contact_id']).to eq attrs[:contact_id]
        expect(json['id']).to eq distributor.id
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end
end
