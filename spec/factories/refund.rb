# frozen_string_literal: true

FactoryBot.define do
  factory :refund do
    square_refund_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    status { %w[PENDING COMPLETED REJECTED FAILED].sample }
    association :payment_intent, factory: :square_payment_intent
  end
end
