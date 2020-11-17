# frozen_string_literal: true

require 'rails_helper'

describe WebhookManager::DonationCreator, '#call' do
  let(:seller) { create :seller }

  it 'creates donation' do
    payment_intent = create :payment_intent
    payload = new_payload(payment_intent)
    donation = WebhookManager::DonationCreator.call(payload)

    item = Item.last

    expect(item.seller).to eq(seller)
    expect(item.purchaser).to eq(payment_intent.purchaser)
    expect(item.item_type).to eq('donation')
    expect(donation.item).to eq(item)
    expect(donation.amount).to eq(payload[:amount])
  end

  def new_payload(payment_intent)
    {
      seller_id: seller.seller_id,
      payment_intent: payment_intent,
      amount: 500
    }
  end
end
