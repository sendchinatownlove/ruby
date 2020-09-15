# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ContactLyftRewards', type: :request do
  before do
    freeze_time
  end

  context 'POST /contacts/:id/lyft_rewards' do
    let!(:contact) { create :contact }
    let(:redeemed_at) do
      Faker::Date.between(
        from: Date.today - 30.days,
        to: Date.today - 1.days
      )
    end
    let!(:participating_seller) do
      create(
        :participating_seller,
        is_lyft_sponsored: true
      )
    end
    let!(:ticket) do
      create(
        :ticket,
        contact: contact,
        participating_seller: participating_seller,
        redeemed_at: redeemed_at
      )
    end
    let!(:lyft_reward) { create :lyft_reward }
    let(:id) { contact.id }

    subject do
      post "/contacts/#{id}/lyft_rewards"
    end

    context 'With a missing contact id' do
      let(:id) { 9999 }

      it 'Returns 404' do
        subject
        expect(response).to have_http_status(404)
      end
    end

    context 'With a contact that is not eligible for lyft rewards' do
      before do
        allow_any_instance_of(Contact).to receive(:is_eligible_for_lyft_reward).and_return(false)
      end

      it 'Returns status code 422' do
        subject
        expect(response).to have_http_status(422)
      end

      it 'Returns a validation failure message' do
        subject
        expect(response.body).to match(
          /Contact is not eligible for Lyft Rewards/
        )
      end
    end

    context 'With a contact that is eligible for lyft rewards' do
      before do
        allow(EmailManager::ContactLyftRewardsSender).to receive(:call)
      end

      it 'Sends an e-mail to the contact' do
        expect(EmailManager::ContactLyftRewardsSender).to receive(:call)
          .once
          .with({
                  contact_id: contact.id,
                  email: contact.email,
                  token: anything
                })
        subject
      end

      it 'Updates the Lyft Rewards record' do
        subject
        updated_lyft_reward = LyftReward.find(lyft_reward.id)
        expect(updated_lyft_reward.expires_at).to eq(Time.now + 72.hours)
        expect(updated_lyft_reward.state).to eq('delivered')
        expect(updated_lyft_reward.contact).to eq(contact)
        expect(updated_lyft_reward.token).not_to be_nil
      end
    end
  end
end
