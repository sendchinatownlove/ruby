# frozen_string_literal: true

# == Schema Information
#
# Table name: existing_events
#
#  id              :bigint           not null, primary key
#  idempotency_key :string
#  type            :integer
#
require 'rails_helper'

RSpec.describe ExistingEvent, type: :model do
  it { should validate_presence_of(:idempotency_key) }
  it { should validate_uniqueness_of(:idempotency_key) }
  it do
    should define_enum_for(:event_type).with(
      %i[charges_create webhooks_create_refund_updated]
    )
  end
end
