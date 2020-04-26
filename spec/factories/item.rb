# frozen_string_literal: true

FactoryBot.define do
  factory :item do
    email { Faker::Internet.email }
    association :seller
    association :payment_intent, factory: :square_payment_intent
    item_type { Faker::Number.within(range: 0..1) }
  end
end
