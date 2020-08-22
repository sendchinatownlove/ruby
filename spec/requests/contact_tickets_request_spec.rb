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
  let!(:redeemed_ticket) do
    create :ticket, contact: contact2, sponsor_seller: sponsor_seller2
  end

  let!(:sponsor_seller1) do
    create :sponsor_seller, reward_cost: 1
  end
  let!(:sponsor_seller2) do
    create :sponsor_seller, reward_cost: 2
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

    it 'returns a not found message' do
      expect(response.body).to match(/Couldn't find Contact/)
    end

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

    context 'when trying to redeem tickets already redeemed' do
      let(:rewards_redemption_access_token) { contact1.rewards_redemption_access_token }
      let(:attrs) do
        {
          tickets: [
            { id: redeemed_ticket.id, sponsor_seller_id: sponsor_seller2.id },
            { id: ticket3.id, sponsor_seller_id: sponsor_seller2.id }
          ]
        }
      end

      it 'returns 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'with correct number of tickets' do
      let(:attrs) do
        {
          tickets: [
            { id: ticket1.id, sponsor_seller_id: sponsor_seller2.id },
            { id: ticket2.id, sponsor_seller_id: sponsor_seller2.id }
          ]
        }
      end

      context 'with invalid rewards_redemption_access_token' do
        let(:rewards_redemption_access_token) do
          contact2.rewards_redemption_access_token
        end

        it 'returns 404' do
          expect(response).to have_http_status(404)
        end
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
            attrs[:tickets][0][:sponsor_seller_id]
          )
          expect(updated_ticket2.sponsor_seller.id).to eq(
            attrs[:tickets][1][:sponsor_seller_id]
          )
        end

        it 'returns 200' do
          expect(response).to have_http_status(200)
        end

        context 'with tickets that this contact does not own' do
          let(:attrs) do
            {
              tickets: [
                { id: ticket1.id, sponsor_seller_id: sponsor_seller1.id },
                { id: ticket3.id, sponsor_seller_id: sponsor_seller2.id } # does not own
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
    end

    context 'with too few tickets' do
      let(:attrs) do
        {
          tickets: [
            # sponsor_seller2 has a reward_cost of 2
            { id: ticket1.id, sponsor_seller_id: sponsor_seller2.id }
          ]
        }
      end
      let(:rewards_redemption_access_token) do
        contact1.rewards_redemption_access_token
      end

      it 'does not redeem tickets because has the wrong reward cost' do
        expect(response.body).to match(/Expected 2 tickets, but got 1/)
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end
    end

    context 'with too many tickets' do
      let(:attrs) do
        {
          tickets: [
            # sponsor_seller1 has a reward_cost of 1
            { id: ticket1.id, sponsor_seller_id: sponsor_seller1.id },
            { id: ticket2.id, sponsor_seller_id: sponsor_seller1.id }
          ]
        }
      end
      let(:rewards_redemption_access_token) do
        contact1.rewards_redemption_access_token
      end

      it 'does not redeem tickets because has the wrong reward cost' do
        expect(response.body).to match(/Expected 1 tickets, but got 2/)
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end
    end
  end
end
