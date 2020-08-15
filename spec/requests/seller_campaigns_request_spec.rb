# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SellerCampaigns', type: :request do
  before do
    @seller = create :seller
    @location = create(:location, seller_id: @seller.id)
    @campaign = create(
      :campaign,
      active: true,
      seller_id: @seller.id,
      location_id: @location.id
    )
    @inactive_campaign = create(
      :campaign,
      active: false,
      seller_id: @seller.id,
      location_id: @location.id
    )
    @invalid_campaign = create(
      :campaign,
      active: false,
      valid: false,
      seller_id: @seller.id,
      location_id: @location.id
    )
  end

  context 'GET /sellers/:seller_id/campaigns' do
    context 'With a missing id' do
      before { get '/sellers/missing-id/campaigns' }

      it 'Returns 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'With a valid id' do
      let(:seller_id) { @seller.seller_id }

      context 'Without an active flag' do
        before { get "/sellers/#{seller_id}/campaigns" }

        it 'Returns all valid campaigns for the seller' do
          expect(json).not_to be_empty
          expect(json.size).to eq(2)

          seller_ids = json.map { |campaign| campaign['seller_id'] }
          expect(seller_ids.all? { |id| id == seller_id }).to be true

          valid_states = json.map { |campaign| campaign['valid'] }
          expect(valid_states.all?).to be true
        end

        it 'Returns 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'With active=true' do
        before { get "/sellers/#{seller_id}/campaigns?active=true" }

        it 'Returns the active campaign' do
          expect(json).not_to be_empty
          expect(json[0]['id']).to eq(@campaign.id)
        end

        it 'Returns 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'With active=false' do
        before { get "/sellers/#{seller_id}/campaigns?active=false" }

        it 'Returns the active campaign' do
          expect(json).not_to be_empty
          expect(json[0]['id']).to eq(@inactive_campaign.id)
        end

        it 'Returns 200' do
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
