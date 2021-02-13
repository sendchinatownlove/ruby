# frozen_string_literal: true

require 'rails_helper'

describe WebhookManager::GiftCardCreator, '#call' do
  let(:seller) { create :seller }
  let!(:campaign) { create(:campaign, :with_project, :with_sellers_distributors, seller: nil) }

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

  context 'when the payment intent does not have a recipient' do
    subject do
      payment_intent = create :payment_intent
      payment_intent.update!(recipient: nil)

      payload = new_payload(payment_intent)
      gift_card_details = WebhookManager::GiftCardCreator.call(payload)
    end

    it 'raises' do
      expect {subject}.to raise_error
    end
  end

  it 'creates gift_card_details without payment intent' do
    gift_card_details = WebhookManager::GiftCardCreator.call({
      seller_id: campaign.seller_distributor_pairs[0]['seller_id'],
      amount: 500,
      single_use: true,
      distributor_id: campaign.seller_distributor_pairs[0]['distributor_id'],
      project_id: campaign.project_id
    })

    item = Item.last
    distributor = Distributor.find(campaign.seller_distributor_pairs[0]['distributor_id'])
    distributor_contact = Contact.find_by(id: distributor.contact_id)
    seller = Seller.find_by(seller_id: campaign.seller_distributor_pairs[0]['seller_id'])

    expect(item.seller).to eq(seller)
    expect(item.item_type).to eq('gift_card')
    expect(gift_card_details.item).to eq(item)
    expect(gift_card_details.amount).to eq(500)
    expect(gift_card_details.recipient).to eq(distributor_contact)
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
