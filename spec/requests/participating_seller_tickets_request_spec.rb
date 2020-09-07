# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ParticipatingSellerTickets', type: :request do
  let!(:ticket1) do
    create :ticket, participating_seller: participating_seller1
  end
  let!(:ticket2) do
    create :ticket, participating_seller: participating_seller1
  end
  let!(:ticket3) do
    create :ticket, participating_seller: participating_seller2
  end

  let!(:participating_seller1) do
    create :participating_seller
  end
  let!(:participating_seller2) do
    create :participating_seller
  end

  context 'with valid participating_seller_id' do
    before { get "/participating_sellers/#{participating_seller_id}/tickets/#{tickets_secret}" }
    let(:participating_seller_id) { participating_seller1.id }

    context 'with valid tickets_secret' do
      let(:tickets_secret) { participating_seller1.tickets_secret }

      it 'returns all the tickets for seller' do
        expect(json['data']).not_to be_empty
        expect(json['data'].size).to eq 2
        expect(json['data']).to eq(
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

    context 'with invalid tickets_secret' do
      let(:tickets_secret) { participating_seller2.tickets_secret }

      it 'returns 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  context 'with invalid participating_seller_id' do
    before { get "/participating_sellers/#{participating_seller_id}/tickets/#{tickets_secret}" }
    let(:participating_seller_id) { 'blahblahblah' }
    let(:tickets_secret) { participating_seller1.tickets_secret }

    it 'returns 404' do
      expect(response).to have_http_status(404)
    end
  end

  context 'without tickets' do
    let!(:participating_seller_with_no_tickets) do
      create :participating_seller
    end
    let(:tickets_secret) { participating_seller_with_no_tickets.tickets_secret }
    let(:participating_seller_id) { participating_seller_with_no_tickets.id }

    before { get "/participating_sellers/#{participating_seller_id}/tickets/#{tickets_secret}" }

    it 'returns empty array' do
      expect(json['data']).to be_empty
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end
  end
end
