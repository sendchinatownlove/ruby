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
