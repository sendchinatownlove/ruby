class Seller < ApplicationRecord
  # model association
  has_many :locations, dependent: :destroy

  validates :founded_year, :inclusion => 1800..2020
  validates_uniqueness_of :seller_id
  validates_inclusion_of :sell_gift_cards, in: [true, false]
  validates_inclusion_of :accept_donations, in: [true, false]
end
