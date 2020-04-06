class GiftCard < ApplicationRecord
  validates_presence_of :charge_id, :merchant_id, :amount, :customer_id
  validates_uniqueness_of :charge_id
  validates_numericality_of :amount, :greater_than_or_equal_to => 0
end
