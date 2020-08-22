# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ContactRewards', type: :request do
  before do
    @contact = create :contact
  end

  context 'POST /contacts/:id/rewards' do
    context 'With a missing contact id' do
      before { post '/contacts/missing/rewards' }

      it 'Returns 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'With an existing contact id' do
      before(:each) do
        allow(EmailManager::ContactRewardsSender).to receive(:call)
      end

      it 'Sends an e-mail to the contact' do
        expect(EmailManager::ContactRewardsSender).to receive(:call)
          .once
          .with({
                  contact_id: @contact.id,
                  email: @contact.email,
                  token: anything
                })

        post "/contacts/#{@contact.id}/rewards"
      end

      it 'Updates the Contact token' do
        post "/contacts/#{@contact.id}/rewards"

        updated_contact = Contact.find(@contact.id)
        expect(updated_contact.rewards_redemption_access_token).not_to eq(@contact.rewards_redemption_access_token)
      end
    end
  end
end
