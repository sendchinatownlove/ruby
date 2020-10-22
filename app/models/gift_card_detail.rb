# frozen_string_literal: true

# == Schema Information
#
# Table name: gift_card_details
#
#  id                  :bigint           not null, primary key
#  expiration          :date
#  single_use          :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  gift_card_id        :string
#  item_id             :bigint           not null
#  receipt_id          :string
#  recipient_id        :bigint           not null
#  seller_gift_card_id :string
#
# Indexes
#
#  index_gift_card_details_on_item_id       (item_id)
#  index_gift_card_details_on_recipient_id  (recipient_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => items.id)
#  fk_rails_...  (recipient_id => contacts.id)
#
class GiftCardDetail < ApplicationRecord
  validates_uniqueness_of :gift_card_id
  validates_presence_of :recipient
  validate :seller_gift_card_id_is_unique_per_seller, on: :create

  belongs_to :item
  belongs_to :recipient, class_name: 'Contact'
  has_many :gift_card_amount

  # TODO(jmckibben): Being used in sellers_helper N times. Ideally we'd combine
  # into a single query
  def amount
    GiftCardAmount.where(gift_card_detail_id: id)
                  .order(created_at: :desc)
                  .first
                  .value
  end

  def last_updated
    GiftCardAmount.where(gift_card_detail_id: id)
                  .order(created_at: :desc)
                  .first
                  .created_at
  end

  def seller_gift_card_id_is_unique_per_seller
    if seller_gift_card_id.present?
      seller_id = item.seller_id
      seller_gift_card_id_is_unique_per_seller = GiftCardDetail
                                                 .where(
                                                   seller_gift_card_id:
                                                   seller_gift_card_id
                                                 )
                                                 .joins(:item)
                                                 .where(items: {
                                                          seller_id: seller_id
                                                        })
                                                 .empty?

      unless seller_gift_card_id_is_unique_per_seller
        errors.add(
          :seller_gift_card_id,
          'seller_gift_card_id must be unique per Seller'
        )
      end
    end
  end
end
