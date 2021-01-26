# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CrawlReceipts', type: :request do
  # Initialize the test data
  let!(:participating_seller) { create(:participating_seller) }
  let!(:payment_intent) { create(:payment_intent) }
  let(:contact) { create(:contact) }
  let(:amount) { 1000 }
  let(:receipt_url) { 'receipturl.com'}

  # Test suite for POST /crawl_receipts
  describe 'POST /crawl_receipts' do

    context 'when request attributes are valid' do
      let(:valid_attributes) do
        {
          participating_seller_id: participating_seller.id,
          contact_id: contact.id,
          amount: 1000,
          receipt_url: receipt_url
        }
      end

      before do
        post(
          "/crawl_receipts",
          params: valid_attributes,
          as: :json
        )
      end

      it 'creates a crawl_receipt' do
        actual_json = json.except('id')
        expected_json = valid_attributes.except('id')
        expected_json['amount'] = amount
        expected_json['receipt_url'] = receipt_url
        expected_json['payment_intent_id'] = nil
        expected_json['redemption_id'] = nil
        expect(actual_json).to eq(expected_json.with_indifferent_access)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when request attributes are invalid' do

    let(:invalid_attributes) do
      {
        invalid: 'yellow'
      }
    end

      before do
        post(
          "/crawl_receipts",
          params: invalid_attributes,
          as: :json
        )
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when there is a payment_intent' do
      let(:payment_intent) { create(:payment_intent) }

      let(:attributes_with_payment_intent) do
        {
          payment_intent_id: payment_intent.id,
          contact_id: contact.id,
          amount: 1000,
          receipt_url: receipt_url
        }
      end
    
      before do
        post(
          "/crawl_receipts",
          params: attributes_with_payment_intent,
          as: :json
        )
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when there is both a participating_seller and payment_intent' do

      let(:attributes_with_both_participating_seller_and_payment_intent) do
        {
          payment_intent_id: payment_intent.id,
          participating_seller_id: participating_seller.id,
          contact_id: contact.id,
          amount: 1000,
          receipt_url: receipt_url
        }
      end
    
      before do
        post(
          "/crawl_receipts",
          params: attributes_with_both_participating_seller_and_payment_intent,
          as: :json
        )
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end

  end
end
