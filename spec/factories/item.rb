# frozen_string_literal: true

FactoryBot.define do
  factory :item do
    association :seller
    association :payment_intent
    association :purchaser, factory: :contact
    item_type { Faker::Number.within(range: 0..1) }
    refunded { false }
  end
end
