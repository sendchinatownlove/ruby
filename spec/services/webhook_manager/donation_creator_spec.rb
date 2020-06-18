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
    expect(PaymentIntent.last.successful).to be true
  end

  it 'does not create donation due to stale data' do
    create :payment_intent

    payment_intent_1 = PaymentIntent.last
    payment_intent_2 = PaymentIntent.last

    payload = new_payload(payment_intent_1)

    donation = WebhookManager::DonationCreator.call(payload)

    item = Item.last
    count = Item.count

    expect(item.seller).to eq(seller)
    expect(item.purchaser).to eq(payment_intent_1.purchaser)
    expect(item.item_type).to eq('donation')
    expect(donation.item).to eq(item)
    expect(donation.amount).to eq(payload[:amount])
    expect(PaymentIntent.last.successful).to be true

    payload = new_payload(payment_intent_2)

    expect { WebhookManager::DonationCreator.call(payload) }
      .to raise_error(ActiveRecord::StaleObjectError)

    expect(count).to eq(Item.count)
  end

  def new_payload(payment_intent)
    {
      seller_id: seller.seller_id,
      payment_intent: payment_intent,
      amount: 50
    }
  end
end
