
FactoryBot.define do
  factory :refund do
    square_refund_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    status { ['PENDING', 'COMPLETED', 'REJECTED', 'FAILED'].sample }
    association :payment_intent, factory: :square_payment_intent
  end
end
