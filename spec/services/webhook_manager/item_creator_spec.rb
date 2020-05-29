# frozen_string_literal: true

require 'rails_helper'

describe WebhookManager::ItemCreator, '#call' do
  let(:seller) { create :seller }
  let(:payment_intent) { create :payment_intent }
  let(:payload) do
    {
      item_type: 'donation',
      seller_id: seller.seller_id,
      payment_intent: payment_intent
    }
  end

  it 'it creates item' do
    WebhookManager::ItemCreator.call(payload)

    item = Item.first

    expect(item.seller).to eq(seller)
    expect(item.purchaser).to eq(payment_intent.purchaser)
    expect(item.item_type).to eq(payload[:item_type])
    expect(payment_intent).to eq(payment_intent)
  end
end
