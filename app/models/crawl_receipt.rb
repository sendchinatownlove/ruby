# frozen_string_literal: true

# == Schema Information
#
# Table name: crawl_receipts
#
#  id                      :bigint           not null, primary key
#  amount                  :integer          not null
#  receipt_url             :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
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
class CrawlReceipt < ApplicationRecord
  belongs_to :participating_seller, optional: true
  belongs_to :payment_intent, optional: true
  validate :has_participating_seller_xor_payment_indent?
  belongs_to :contact
  belongs_to :redemption, optional: true
  validates_presence_of :amount
  belongs_to :participating_seller, optional: true
  belongs_to :payment_intent, optional: true

  def has_participating_seller_xor_payment_indent?
    unless participating_seller.present? ^ payment_intent.present?
      errors.add('Participating Seller or Payment Intent must exist, but not both')
    end
  end

  def amount_greater_than_10_00
    errors.add('Amount must be greater or equal to $10') unless amount >= 10_00
  end
end
