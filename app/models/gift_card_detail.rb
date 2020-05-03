# frozen_string_literal: true

# == Schema Information
#
# Table name: gift_card_details
#
#  id                  :bigint           not null, primary key
#  gift_card_id        :string
#  receipt_id          :string
#  expiration          :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  item_id             :bigint           not null
#  seller_gift_card_id :string
#
class GiftCardDetail < ApplicationRecord
  belongs_to :item
  validates_uniqueness_of :gift_card_id
  validate :seller_gift_card_id_is_unique_per_seller
  has_many :gift_card_amount

  # TODO(jmckibben): Being used in sellers_helper N times. Ideally we'd combine
  # into a single query
  def amount
    GiftCardAmount.where(gift_card_detail_id: id)
                  .order(updated_at: :desc)
                  .first
                  .value
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
