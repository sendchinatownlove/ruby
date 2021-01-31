# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ContactRedemptions', type: :request do
  let(:contact) { create :contact }
  let(:reward) { create :reward }
  let(:redemption) { create :redemption, contact: contact, reward: reward }

  describe 'GET /contacts/:id/redemptions' do
    it 'returns http success and the appropriate body' do
      get "/contacts/#{contact.id}/redemptions", as: :json
      expect(response).to have_http_status(:success)
    end
  end
end
