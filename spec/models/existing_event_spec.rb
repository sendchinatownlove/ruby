# frozen_string_literal: true

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
