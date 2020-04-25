require 'rails_helper'

RSpec.describe ExistingEvent, type: :model do
  it { should validate_presence_of(:idempotency_key) }
  it { should validate_uniqueness_of(:idempotency_key) }
  it do
    should define_enum_for(:type).with([:charges_create, :webhooks_create_refund_updated])
  end
end
