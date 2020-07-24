# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Campaigns API', type: :request do
  before do
    @seller = create :seller
    @location = create(:location, seller_id: @seller.id)
    @campaign = create(:campaign, seller_id: @seller.id, location_id: @location.id)
  end

  context 'GET /campaigns' do
    before { get '/campaigns' }

    it 'Returns campaigns' do
      expect(json).not_to be_empty
      expect(json.size).to eq(1)
    end

    it 'Returns 200' do
      expect(response).to have_http_status(200)
    end
  end

  context 'GET /campaigns/:id' do
    before { get "/campaigns/#{campaign_id}" }

    context 'With a missing id' do
      let(:campaign_id) { 'missing_id' }

      it 'Returns 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'With valid id' do
      let(:campaign_id) { @campaign.id }

      it 'Returns the campaign' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(@campaign.id)
      end

      it 'Returns 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'POST /campaigns' do
    context 'With invalid parameters' do
      before { post '/campaigns', params: {} }

      it 'Returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end

    context 'With valid parameters' do
      before do
        post(
          '/campaigns',
          params: {
            end_date: Date.tomorrow,
            location_id: @location.id,
            seller_id: @seller.seller_id,
          },
          as: :json,
        )
      end

      it 'Returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end
  end

  context 'PUT /campaigns' do
    before do
      put(
        "/campaigns/#{campaign_id}",
        params: body,
        as: :json,
      )
    end

    context 'With a missing id' do
      let(:campaign_id) { 'missing_id' }

      it 'Returns 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'With a valid id' do
      let(:campaign_id) { @campaign.id }
      let(:body) do
        {
          description: 'Campaign description',
          gallery_image_urls: ['https://reddit.com/123.png'],
        }
      end

      it 'Returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'Returns the campaign with updated fields' do
        expect(json['description']).to eq(body[:description])
        expect(json['gallery_image_urls']).to eq(body[:gallery_image_urls])
      end

      it 'Updates the fields in the record' do
        updated_campaign = Campaign.find(@campaign.id)
        expect(updated_campaign.description).to eq(body[:description])
        expect(updated_campaign.gallery_image_urls).to eq(body[:gallery_image_urls])
      end
    end
  end
end
