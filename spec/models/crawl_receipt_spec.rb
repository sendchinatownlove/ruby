# frozen_string_literal: true

# == Schema Information
#
# Table name: crawl_receipts
#
#  id                      :bigint           not null, primary key
#  amount                  :integer          not null
#  receipt_url             :string           not null
#  contact_id              :bigint           not null
#  participating_seller_id :bigint
#  payment_intent_id       :bigint
#  redemption_id           :bigint
#
# Indexes
#
#  index_crawl_receipts_on_contact_id               (contact_id)
#  index_crawl_receipts_on_participating_seller_id  (participating_seller_id)
#  index_crawl_receipts_on_payment_intent_id        (payment_intent_id)
#  index_crawl_receipts_on_redemption_id            (redemption_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#  fk_rails_...  (participating_seller_id => participating_sellers.id)
#  fk_rails_...  (payment_intent_id => payment_intents.id)
#  fk_rails_...  (redemption_id => redemptions.id)
#

require 'rails_helper'

RSpec.describe CrawlReceipt, type: :model do
    it { should belong_to(:contact) }
    it { should validate_presence_of(:amount) }

  context 'when creating a crawl receipt with only a participating seller' do
    let(:crawl_receipt) do
      create(:crawl_receipt, :with_participating_seller)
    end

    it 'is successful' do
      crawl_receipt
    end
  end

  context 'when creating a crawl receipt with only a payment intent' do
    let(:crawl_receipt) do
      create(:crawl_receipt, :with_payment_intent)
    end

    it 'is successful' do
      crawl_receipt
    end
  end

  context 'when creating a crawl receipt with both a participating seller and a payment intent' do
    let(:participating_seller) { create(:participating_seller) }
    let(:payment_intent) { create(:payment_intent) }
    subject { CrawlReceipt.create(participating_seller: participating_seller, payment_intent: payment_intent) }

    it 'throws an error' do
      expect(subject).to_not be_valid
    end
  end

  context 'when creating a crawl receipt with neither a participating seller and a payment intent' do
    subject { CrawlReceipt.create }

    it 'throws an error' do
      expect(subject).to_not be_valid
    end
  end
end
