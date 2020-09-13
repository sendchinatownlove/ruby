# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ContactRewards', type: :request do
  before do
    freeze_time
  end

  context 'POST /contacts/:id/rewards' do
    let!(:contact) { create :contact, expires_at: Time.now }
    context 'With a missing contact id' do
      before { post '/contacts/missing/rewards' }

      it 'Returns 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'with token that has expired' do
      before(:each) do
        allow(Time).to receive(:now).and_return(Time.now - 1.minute)
      end

      context 'With an existing contact id' do
        before(:each) do
          allow(EmailManager::ContactRewardsSender).to receive(:call)
          allow(Time).to receive(:now).and_return(Time.now - 1.minute)
        end

        it 'Sends an e-mail to the contact' do
          expect(EmailManager::ContactRewardsSender).to receive(:call)
            .once
            .with({
                    contact_id: contact.id,
                    email: contact.email,
                    token: anything
                  })

          post "/contacts/#{contact.id}/rewards"
        end

        it 'does not update the Contact token' do
          post "/contacts/#{contact.id}/rewards"

          updated_contact = Contact.find(contact.id)
          expect(updated_contact.rewards_redemption_access_token).to eq(contact.rewards_redemption_access_token)
          expect(updated_contact.expires_at).to eq(Time.now + 30.minutes)
        end

        context 'with nil expires at' do
          let!(:contact) { create :contact, expires_at: nil }

          it 'Sends an e-mail to the contact' do
            expect(EmailManager::ContactRewardsSender).to receive(:call)
              .once
              .with({
                      contact_id: contact.id,
                      email: contact.email,
                      token: anything
                    })

            post "/contacts/#{contact.id}/rewards"
          end

          it 'updates the Contact token' do
            post "/contacts/#{contact.id}/rewards"

            updated_contact = Contact.find(contact.id)
            expect(updated_contact.rewards_redemption_access_token).not_to eq(contact.rewards_redemption_access_token)
            expect(updated_contact.expires_at).to eq(Time.now + 30.minutes)
          end
        end
      end
    end

    context 'with token that has not expired' do
      context 'With an existing contact id' do
        before(:each) do
          allow(EmailManager::ContactRewardsSender).to receive(:call)
        end

        it 'Sends an e-mail to the contact' do
          expect(EmailManager::ContactRewardsSender).to receive(:call)
            .once
            .with({
                    contact_id: contact.id,
                    email: contact.email,
                    token: anything
                  })

          post "/contacts/#{contact.id}/rewards"
        end

        it 'updates the Contact token' do
          post "/contacts/#{contact.id}/rewards"

          updated_contact = Contact.find(contact.id)
          expect(updated_contact.rewards_redemption_access_token).not_to eq(contact.rewards_redemption_access_token)
          expect(updated_contact.expires_at).to eq(Time.now + 30.minutes)
        end

        context 'with nil expires at' do
          let!(:contact) { create :contact, expires_at: nil }

          it 'Sends an e-mail to the contact' do
            expect(EmailManager::ContactRewardsSender).to receive(:call)
              .once
              .with({
                      contact_id: contact.id,
                      email: contact.email,
                      token: anything
                    })

            post "/contacts/#{contact.id}/rewards"
          end

          it 'updates the Contact token' do
            post "/contacts/#{contact.id}/rewards"

            updated_contact = Contact.find(contact.id)
            expect(updated_contact.rewards_redemption_access_token).not_to eq(contact.rewards_redemption_access_token)
            expect(updated_contact.expires_at).to eq(Time.now + 30.minutes)
          end
        end
      end
    end
  end
end
