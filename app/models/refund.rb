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
class Refund < ApplicationRecord
  validates_uniqueness_of :square_refund_id
  belongs_to :payment_intent
  validates_inclusion_of :status, in: %w[PENDING COMPLETED REJECTED FAILED]
end
