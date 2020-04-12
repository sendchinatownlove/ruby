FactoryBot.define do
  factory :item do
    email { Faker::Internet.email }
    association :seller
    association :payment_intent
    item_type { Faker::Number.within(range: 0..1) }
  end
end
