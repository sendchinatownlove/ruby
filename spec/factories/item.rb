FactoryBot.define do
  factory :item do
    stripe_customer_id { Faker::Alphanumeric.alphanumeric(digits: 64) }
    association :seller
    item_type { Faker::Number.within(range: 1..2) }
    association :gift_card_detail
    association :donation_detail
  end
end
