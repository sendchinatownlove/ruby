# frozen_string_literal: true

require 'rails_helper'

describe WebhookManager::PoolDonationCreator, '#call' do
  let(:seller) { create :seller, accept_donations: true }

  it 'creates donation' do
    # Initialize more than one seller
    create :seller, accept_donations: true

    payment_intent = create :payment_intent
    payload = new_payload(payment_intent)
    donations = WebhookManager::PoolDonationCreator.call(payload)

    expect(Item.count).to eq(2)
    expect(DonationDetail.count).to eq(Item.count)
    donations.each do |donation|
      expect(donation.amount).to eq(payload[:amount] / 2)
      item = donation.item
      expect(item.purchaser).to eq(payment_intent.purchaser)
      expect(item.item_type).to eq('donation')
    end
  end

  def new_payload(payment_intent)
    {
      seller_id: seller.seller_id,
      payment_intent: payment_intent,
      amount: 500
    }
  end
end
