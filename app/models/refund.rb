# frozen_string_literal: true

# == Schema Information
#
# Table name: refunds
#
#  id                :bigint           not null, primary key
#  status            :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  payment_intent_id :bigint           not null
#  square_refund_id  :string
#
# Indexes
#
#  index_refunds_on_payment_intent_id  (payment_intent_id)
#
# Foreign Keys
#
#  fk_rails_...  (payment_intent_id => payment_intents.id)
#
class Refund < ApplicationRecord
  validates_uniqueness_of :square_refund_id
  belongs_to :payment_intent
  validates_inclusion_of :status, in: %w[PENDING COMPLETED REJECTED FAILED]
end
