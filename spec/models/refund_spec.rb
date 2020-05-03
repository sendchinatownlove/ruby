# frozen_string_literal: true

# == Schema Information
#
# Table name: refunds
#
#  id                :bigint           not null, primary key
#  square_refund_id  :string
#  status            :string
#  payment_intent_id :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'rails_helper'

RSpec.describe Refund, type: :model do
  subject { create :refund }
  it { should belong_to(:payment_intent) }
  it { should validate_uniqueness_of(:square_refund_id) }
  it do
    should allow_values('PENDING', 'COMPLETED', 'REJECTED', 'FAILED')
      .for(:status)
  end
end
