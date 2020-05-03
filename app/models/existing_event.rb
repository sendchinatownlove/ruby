# frozen_string_literal: true

# == Schema Information
#
# Table name: existing_events
#
#  id              :bigint           not null, primary key
#  idempotency_key :string
#  type            :integer
#
class ExistingEvent < ApplicationRecord
  validates_presence_of :idempotency_key, :event_type
  validates_uniqueness_of :idempotency_key
  enum event_type: %i[charges_create webhooks_create_refund_updated]
end
