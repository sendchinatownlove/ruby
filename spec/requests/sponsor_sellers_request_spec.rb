# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SponsorSellers', type: :request do
  # Test suite for GET /sellers
  describe 'GET /sponsor_sellers' do
    let!(:sponsor_seller1) { create :sponsor_seller }
    let!(:sponsor_seller2) { create :sponsor_seller }
    let!(:sponsor_seller_inactive) { create :sponsor_seller, active: false }
    before { get '/sponsor_sellers' }

    it 'returns only active sponsor sellers' do
      expect(json).not_to be_empty
      expect(json.size).to eq(2)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /sponsor_sellers/:id' do
    let!(:sponsor_seller) { create :sponsor_seller }
    before { get "/sponsor_sellers/#{sponsor_seller_id}" }

    context 'with valid sponsor_seller_id' do
      let(:sponsor_seller_id) { sponsor_seller.id }

      it 'returns the sponsor_seller' do
        expect(json['id']).to eq sponsor_seller.id
        expect(json['reward_cost']).to eq sponsor_seller.reward_cost
        expect(json['reward']).to eq sponsor_seller.reward
        expect(json['reward_detail']).to eq sponsor_seller.reward_detail
        expect(json['logo_url']).to eq sponsor_seller.logo_url
        expect(json['location_id']).to eq sponsor_seller.location_id
        expect(json['name']).to eq sponsor_seller.name
        expect(json['active']).to eq sponsor_seller.active
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid distributor_id' do
      let(:sponsor_seller_id) { 'rrarararararararr' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find SponsorSeller/)
      end
    end
  end

  describe 'POST /sponsor_seller' do
    let!(:location) { create :location }
    before do
      post(
        '/sponsor_sellers',
        params: attrs,
        as: :json
      )
    end

    context 'with valid attrs' do
      let(:attrs) do
        {
          location_id: location.id,
          name: 'Boys Sometimes Cry',
          logo_url: 'sendchinatownlove.com/lalalllala',
          reward: 'Free Shot in the Dark',
          reward_cost: 3,
          reward_detail: 'only valid after sunset',
          active: true
        }
      end

      it 'creates the sponsor seller' do
        sponsor_seller = SponsorSeller.find(json['id'])

        expect(json['id']).to eq sponsor_seller.id
        expect(json['reward_cost']).to eq sponsor_seller.reward_cost
        expect(json['reward']).to eq sponsor_seller.reward
        expect(json['reward_detail']).to eq sponsor_seller.reward_detail
        expect(json['logo_url']).to eq sponsor_seller.logo_url
        expect(json['location_id']).to eq sponsor_seller.location_id
        expect(json['name']).to eq sponsor_seller.name
        expect(json['active']).to eq sponsor_seller.active

        expect(sponsor_seller).not_to be_nil
        expect(sponsor_seller.reward_cost).to eq attrs[:reward_cost]
        expect(sponsor_seller.reward).to eq attrs[:reward]
        expect(sponsor_seller.reward_detail).to eq attrs[:reward_detail]
        expect(sponsor_seller.logo_url).to eq attrs[:logo_url]
        expect(sponsor_seller.location_id).to eq attrs[:location_id]
        expect(sponsor_seller.name).to eq attrs[:name]
        expect(sponsor_seller.active).to eq attrs[:active]
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'with extra attrs' do
      let(:attrs) do
        {
          location_id: location.id,
          name: 'Boys Sometimes Cry',
          logo_url: 'sendchinatownlove.com/lalalllala',
          reward: 'Free Shot in the Dark',
          reward_cost: 3,
          active: true,
          extra: 'bllah'
        }
      end

      it 'creates the sponsor seller' do
        sponsor_seller = SponsorSeller.find(json['id'])

        expect(json['id']).to eq sponsor_seller.id
        expect(json['reward_cost']).to eq sponsor_seller.reward_cost
        expect(json['reward']).to eq sponsor_seller.reward
        expect(json['reward_detail']).to eq sponsor_seller.reward_detail
        expect(json['logo_url']).to eq sponsor_seller.logo_url
        expect(json['location_id']).to eq sponsor_seller.location_id
        expect(json['name']).to eq sponsor_seller.name
        expect(json['active']).to eq sponsor_seller.active

        expect(sponsor_seller).not_to be_nil
        expect(sponsor_seller.reward_cost).to eq attrs[:reward_cost]
        expect(sponsor_seller.reward).to eq attrs[:reward]
        expect(sponsor_seller.reward_detail).to eq attrs[:reward_detail]
        expect(sponsor_seller.logo_url).to eq attrs[:logo_url]
        expect(sponsor_seller.location_id).to eq attrs[:location_id]
        expect(sponsor_seller.name).to eq attrs[:name]
        expect(sponsor_seller.name).to eq attrs[:name]
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end
  end

  describe 'PUT /sponsor_sellers/:id' do
    let!(:sponsor_seller) { create :sponsor_seller }
    let!(:location) { create :location }
    before do
      put(
        "/sponsor_sellers/#{sponsor_seller_id}",
        params: attrs,
        as: :json
      )
    end

    context 'with valid attrs' do
      let(:sponsor_seller_id) { sponsor_seller.id }
      let(:attrs) do
        {
          location_id: location.id,
          name: 'Boys Sometimes Cry',
          logo_url: 'sendchinatownlove.com/lalalllala',
          reward: 'Free Shot in the Dark',
          reward_cost: 3,
          reward_detail: 'only valid after sunset',
          active: true
        }
      end

      it 'updates the sponsor_seller' do
        sponsor_seller = SponsorSeller.find(json['id'])
        expect(sponsor_seller).not_to be_nil
        expect(sponsor_seller.reward_cost).to eq attrs[:reward_cost]
        expect(sponsor_seller.reward).to eq attrs[:reward]
        expect(sponsor_seller.reward_detail).to eq attrs[:reward_detail]
        expect(sponsor_seller.logo_url).to eq attrs[:logo_url]
        expect(sponsor_seller.location_id).to eq attrs[:location_id]
        expect(sponsor_seller.name).to eq attrs[:name]
        expect(sponsor_seller.active).to eq attrs[:active]
      end

      it 'returns the updated distributor' do
        expect(json['id']).to eq sponsor_seller.id
        sponsor_seller = SponsorSeller.find(json['id'])
        expect(json['reward_cost']).to eq sponsor_seller.reward_cost
        expect(json['reward']).to eq sponsor_seller.reward
        expect(json['reward_detail']).to eq sponsor_seller.reward_detail
        expect(json['logo_url']).to eq sponsor_seller.logo_url
        expect(json['location_id']).to eq sponsor_seller.location_id
        expect(json['name']).to eq sponsor_seller.name
        expect(json['active']).to eq sponsor_seller.active
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end
end
