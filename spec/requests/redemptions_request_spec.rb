require 'rails_helper'

RSpec.describe "/redemptions", type: :request do
  # Setup models
  let(:participating_seller) { create :participating_seller }
  let(:contact) { create :contact }
  let(:reward) { create :reward}

  # Static attribute sets for testing
  let(:base_attributes) do
    {
      contact_id: contact.id,
      reward_id: reward.id
    }
  end

  # Test suite for POST /redemptions
  describe 'POST /redemptions' do
    it 'returns an error when a contact doesn\'t have enough receipts' do
        post redemptions_url,
             params: base_attributes, as: :json
        expect(response).to have_http_status(:bad_request)
    end
    
    it 'creates and returns a redemption when the contact has 3 or more receipts' do
        3.times do
            create :crawl_receipt, contact: contact, participating_seller: participating_seller
        end

        expect do
            post redemptions_url,
                params: base_attributes, as: :json
        end.to change(Redemption, :count).by(1)
        expect(response).to have_http_status(:created)
    end
  end
end
