# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ContactTickets', type: :request do
  let!(:contact1) do
    create :contact
  end
  let!(:contact2) do
    create :contact
  end

  let!(:ticket1) do
    create :ticket, contact: contact1
  end
  let!(:ticket2) do
    create :ticket, contact: contact1
  end
  let!(:ticket3) do
    create :ticket, contact: contact2
  end

  let(:sponsor_seller1) do
    create :sponsor_seller
  end
  let(:sponsor_seller2) do
    create :sponsor_seller
  end

  context 'with valid contact id' do
    before { get "/contacts/#{contact_id}/tickets" }
    let(:contact_id) { contact1.id }

    it 'returns all the tickets this contact has redeemed' do
      expect(json).not_to be_empty
      expect(json.size).to eq 2
      expect(json).to eq(
        [
          ticket1.as_json,
          ticket2.as_json
        ]
      )
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end
  end

  context 'with invalid contact_id' do
    before { get "/contacts/#{contact_id}/tickets" }
    let(:contact_id) { 9999 }

    it 'returns 404' do
      expect(response).to have_http_status(404)
    end
  end

  context 'without tickets' do
    let!(:contact3) { create :contact }
    before { get "/contacts/#{contact3.id}/tickets" }

    it 'returns empty array' do
      expect(json).to be_empty
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end
  end

  context 'with valid contact id' do
    before do
      put(
        "/contacts/#{contact_id}/tickets/#{rewards_redemption_access_token}",
        params: attrs,
        as: :json
      )
    end
    let(:contact_id) { contact1.id }
    let(:attrs) do
      {
        tickets: [
          { id: ticket1.id, redeemed_at: sponsor_seller1.id },
          { id: ticket2.id, redeemed_at: sponsor_seller2.id }
        ]
      }
    end

    context 'with valid rewards_redemption_access_token' do
      let(:rewards_redemption_access_token) { contact1.rewards_redemption_access_token }

      it 'returns all the tickets that have been updated' do
        expect(json).not_to be_empty
        expect(json.size).to eq 2
        updated_ticket1 = Ticket.find(json[0]['id'])
        updated_ticket2 = Ticket.find(json[1]['id'])
        expect(json).to eq(
          [
            updated_ticket1.as_json,
            updated_ticket2.as_json
          ]
        )
        expect(updated_ticket1.sponsor_seller.id).to eq(
          attrs[:tickets][0][:redeemed_at]
        )
        expect(updated_ticket2.sponsor_seller.id).to eq(
          attrs[:tickets][1][:redeemed_at]
        )
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      context 'with invalid tickets' do
        let(:attrs) do
          {
            tickets: [
              { id: ticket1.id, redeemed_at: sponsor_seller1.id },
              { id: ticket3.id, redeemed_at: sponsor_seller2.id }
            ]
          }
        end

        it 'does not update any tickets' do
          updated_ticket1 = Ticket.find(ticket1.id)
          updated_ticket3 = Ticket.find(ticket3.id)
          expect(updated_ticket3.sponsor_seller).to be_nil
          expect(updated_ticket1.sponsor_seller).to be_nil
        end

        it 'returns 404' do
          expect(response).to have_http_status(404)
        end
      end
    end

    context 'with invalid rewards_redemption_access_token' do
      let(:rewards_redemption_access_token) { contact2.rewards_redemption_access_token }

      it 'returns 404' do
        expect(response).to have_http_status(404)
      end
    end
  end
end
