# frozen_string_literal: true

class Seller < ApplicationRecord
  # model association
  has_many :locations, dependent: :destroy
  has_many :menu_items, dependent: :destroy
  has_many :delivery_options, dependent: :destroy

  validates_presence_of :seller_id
  validates_presence_of :square_location_id

  validates_inclusion_of :founded_year, in: 1800..2020
  validates_uniqueness_of :seller_id
  validates_uniqueness_of :square_location_id
  validates_inclusion_of :sell_gift_cards, in: [true, false]
  validates_inclusion_of :accept_donations, in: [true, false]
end
