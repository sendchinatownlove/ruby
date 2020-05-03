# frozen_string_literal: true

class ExistingEvent < ApplicationRecord
  validates_presence_of :idempotency_key, :event_type
  validates_uniqueness_of :idempotency_key
  enum event_type: %i[charges_create webhooks_create_refund_updated]
end
