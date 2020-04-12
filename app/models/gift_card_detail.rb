class GiftCardDetail < ApplicationRecord
  belongs_to :item
  validates_uniqueness_of :gift_card_id
  validate :seller_gift_card_id_is_unique_per_seller
  has_many :gift_card_amount

  def seller_gift_card_id_is_unique_per_seller
    if seller_gift_card_id.present?
      seller_id = item.seller_id
      seller_gift_card_id_is_unique_per_seller = GiftCardDetail.where(seller_gift_card_id: seller_gift_card_id)
                                                               .joins(:item)
                                                               .where(items: { seller_id: seller_id })
                                                               .empty?
      unless seller_gift_card_id_is_unique_per_seller
        errors.add(:seller_gift_card_id, 'seller_gift_card_id must be unique per Seller')
      end
    end
  end
end
