# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Refund, type: :model do
  subject { create :refund }
  it { should belong_to(:payment_intent) }
  it { should validate_uniqueness_of(:square_refund_id) }
  it do
    should allow_values('PENDING', 'COMPLETED', 'REJECTED', 'FAILED').for(:status)
  end
end
