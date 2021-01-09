# == Schema Information
#
# Table name: crawl_receipts
#
#  id                      :bigint           not null, primary key
#  amount                  :integer
#  receipt_url             :string
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

    validate :has_participating_seller_xor_payment_indent?
    belongs_to :contact
    validates_presence_of :amount
    validates_presence_of :receipt_url

    def has_participating_seller_xor_payment_indent?
        unless participating_seller.present? ^ payment_intent.present?
            errors.add(:participating_seller, 'Participating Seller or Payment Intent must exist, but not both')
            errors.add(:payment_intent, 'Participating Seller or Payment Intent must exist, but not both')
        end
    end
end
