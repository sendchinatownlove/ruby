class GiftCard < ApplicationRecord
  validates_presence_of :charge_id, :merchant_id, :amount
end
