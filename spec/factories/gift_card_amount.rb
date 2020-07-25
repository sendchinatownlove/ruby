# frozen_string_literal: true

FactoryBot.define do
  factory :gift_card_amount do
    value { Faker::Number.number(digits: 4) }
    association :gift_card_detail
  end
end
