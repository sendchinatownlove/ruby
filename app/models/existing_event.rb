# frozen_string_literal: true

class ExistingEvent < ApplicationRecord
  validates_presence_of :idempotency_key, :type
  validates_uniqueness_of :idempotency_key
  enum type: %i[charges_create webhooks_create_refund_updated]
end
