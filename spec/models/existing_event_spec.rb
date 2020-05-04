# frozen_string_literal: true

# == Schema Information
#
# Table name: existing_events
#
#  id              :bigint           not null, primary key
#  event_type      :integer
#  idempotency_key :string
#
# Indexes
#
#  index_existing_events_on_idempotency_key_and_event_type  (idempotency_key,event_type) UNIQUE
#
require 'rails_helper'

RSpec.describe ExistingEvent, type: :model do
  it { should validate_presence_of(:idempotency_key) }
  it { should validate_uniqueness_of(:idempotency_key).scoped_to(:event_type) }
  it do
    should define_enum_for(:event_type).with(
      %i[
        charges_create
        payment_updated
        refund_created
        refund_updated
      ]
    )
  end
end
