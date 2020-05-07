# frozen_string_literal: true

FactoryBot.define do
  factory :item do
    email { Faker::Internet.email }
    association :seller
    association :payment_intent
    item_type { Faker::Number.within(range: 0..1) }

    trait :donation_item do
      item_type { :donation }
    end

    trait :gift_card_item do
      item_type { :gift_card }
    end
  end
end
