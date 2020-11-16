# frozen_string_literal: true

FactoryBot.define do
  factory :fee do
    multiplier { Faker::Number.positive(from: 0.01, to: 0.10) }
    flat_cost { Faker::Number.positive(from: 0.10, to: 0.90)}
    name { Faker::Bank.name }
    active { true }
  end
end
