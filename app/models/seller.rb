class Seller < ApplicationRecord
  validates_uniqueness_of :url
  validates_inclusion_of :sell_gift_cards, in: [true, false]
  validates_inclusion_of :accept_donations, in: [true, false]
end
