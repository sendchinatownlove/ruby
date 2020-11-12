# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do
  describe 'GET /campaigns/:id' do
    let(:response) { get :index }
    let!(:campaign) { create :campaign, :with_seller_distributor_pairs }

    it 'returns successful response' do
      campaign = JSON.parse(response.body)
      p campaign
      expect(campaign.size).to eq 1
      expect(campaign[0]['id']).to eq fee.id
    end
  end
end
