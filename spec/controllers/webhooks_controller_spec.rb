# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe 'POST create' do
    let!(:payment_intent) do
      create :payment_intent, :with_line_items, square_payment_id: 'square-id', square_location_id: ENV['SQUARE_LOCATION_ID']
    end
    let!(:seller_a) do
      create :seller, seller_id: 42, name: 'Toasty Buns'
    end
    let!(:seller_b) do
      create :seller, seller_id: 43, name: 'Krusty Krab'
    end

    before(:each) do
      allow(EmailManager::DonationReceiptSender).to receive(:call).and_return(nil)
      allow(SquareManager::WebhookValidator).to receive(:call).and_return(nil)
      allow(DuplicateRequestValidator).to receive(:call).and_return(nil)
    end

    context "for 'Gift A Meal' purchases" do
      it 'should send one email per unique seller ID' do
        line_items_hash = JSON.parse payment_intent.line_items
        seller_ids = line_items_hash.map { |li| li['seller_id'] }
        seller_ids.uniq.length.should == 2

        expect(EmailManager::DonationReceiptSender).to receive(:call).twice
        post :create, body: request_body
      end
    end
  end

  ### HELPERS ###
  def request_body
    {
      type: 'payment_updated',
      data: {
        object: {
          payment: {
            id: payment_intent.square_payment_id,
            location_id: payment_intent.square_location_id,
            status: 'COMPLETED'
          }
        }
      }
    }.to_json
  end
end
