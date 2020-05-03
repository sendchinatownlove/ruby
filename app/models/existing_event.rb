# frozen_string_literal: true

class ExistingEvent < ApplicationRecord
  validates_presence_of :idempotency_key, :event_type
  validates_uniqueness_of :idempotency_key, scope: :event_type
  enum event_type: %i[
    charges_create
    payment_updated
    refund_created
    refund_updated
  ]
end
