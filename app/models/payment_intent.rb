# frozen_string_literal: true

class PaymentIntent < ApplicationRecord
  validates_presence_of :square_payment_id, :square_location_id
  validates_uniqueness_of :square_payment_id, allow_nil: false
  has_many :items
end
