# frozen_string_literal: true

require 'rails_helper'

describe WebhookManager::GiftCardCreator, '#call' do
  let(:seller) { create :seller }

  it 'creates gift_card_details' do
    payment_intent = create :payment_intent

    payload = new_payload(payment_intent)
    gift_card_details = WebhookManager::GiftCardCreator.call(payload)

    item = Item.last

    expect(item.seller).to eq(seller)
    expect(item.purchaser).to eq(payment_intent.purchaser)
    expect(item.item_type).to eq('gift_card')
    expect(gift_card_details.item).to eq(item)
    expect(gift_card_details.amount).to eq(payload[:amount])
    expect(gift_card_details.recipient).to eq(payment_intent.recipient)
    expect(PaymentIntent.last.successful).to be true
  end

  it 'does not create gift_card_details due to stale data' do
    create :payment_intent

    payment_intent_1 = PaymentIntent.last
    payment_intent_2 = PaymentIntent.last

    payload = new_payload(payment_intent_1)

    gift_card_details = WebhookManager::GiftCardCreator.call(payload)

    item = Item.last
    count = Item.count

    expect(item.seller).to eq(seller)
    expect(item.purchaser).to eq(payment_intent_1.purchaser)
    expect(item.item_type).to eq('gift_card')
    expect(gift_card_details.item).to eq(item)
    expect(gift_card_details.amount).to eq(payload[:amount])
    expect(gift_card_details.recipient).to eq(payment_intent_1.recipient)
    expect(PaymentIntent.last.successful).to be true

    payload = new_payload(payment_intent_2)

    expect { WebhookManager::GiftCardCreator.call(payload) }
      .to raise_error(ActiveRecord::StaleObjectError)

    expect(count).to eq(Item.count)
  end

  def new_payload(payment_intent)
    {
      seller_id: seller.seller_id,
      payment_intent: payment_intent,
      amount: 500,
      single_use: true
    }
  end
end
