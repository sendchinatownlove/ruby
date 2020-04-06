FactoryBot.define do
  factory :gift_card do
    charge_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    customer_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    merchant_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    amount { Faker::Number.number(digits: 4) }
  end
end
