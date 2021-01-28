# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ContactCrawlReceipts', type: :request do
  context 'GET /contacts/:contact_id/crawl_receipts' do
    subject do
      get "/contacts/#{contact.id}/crawl_receipts"
    end

    context 'With a contact with a crawl_receipt' do
      let!(:contact) { create :contact }
      let!(:crawl_receipt) { create(:crawl_receipt, :with_participating_seller, contact_id: contact.id) }
      it 'Returns 200' do
        subject
        expect(response).to have_http_status(200)
      end

      it 'Returns the crawl_receipts' do
        subject
        expect(json).not_to be_empty
        binding.pry
      end
    end

    context 'With a contact with multiple crawl_receipts' do
      let!(:contact) { create :contact }
      let!(:crawl_receipt1) { create(:crawl_receipt, :with_participating_seller, contact_id: contact.id) }
      let!(:crawl_receipt2) { create(:crawl_receipt, :with_participating_seller, contact_id: contact.id) }
      let!(:crawl_receipt3) { create(:crawl_receipt, :with_participating_seller, contact_id: contact.id) }
      it 'Returns 200' do
        subject
        expect(response).to have_http_status(200)
      end

      it 'Returns the crawl_receipts' do
        subject
        expect(json.count).to eq(3)
      end
    end
  end
end
