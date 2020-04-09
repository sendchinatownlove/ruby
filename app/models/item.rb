class Item < ApplicationRecord
  belongs_to :seller
  has_one :gift_card_detail
end
