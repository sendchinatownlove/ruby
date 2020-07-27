# frozen_string_literal: true

FactoryBot.define do
  factory :fee do
    multiplier { Faker::Number.decimal(l_digits: 2) }
    active { true }
    association :seller
  end
end
