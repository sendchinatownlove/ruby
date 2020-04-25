class Refund < ApplicationRecord
  validates_uniqueness_of :square_refund_id
  belongs_to :payment_intent
  validates_inclusion_of :status, in: ['PENDING', 'COMPLETED', 'REJECTED', 'FAILED']
end
