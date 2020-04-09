class GiftCardDetail < ApplicationRecord
  belongs_to :item
  validates_uniqueness_of :gift_card_id
  has_many :gift_card_amount
end
