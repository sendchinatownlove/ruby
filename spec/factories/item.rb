FactoryBot.define do
  factory :item do
    stripe_customer_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    association :seller
    item_type { Faker::Number.within(range: 0..1) }
  end
end
