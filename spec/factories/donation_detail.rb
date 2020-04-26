# frozen_string_literal: true

FactoryBot.define do
  factory :donation_detail do
    amount { Faker::Number.number(digits: 3) }
  end
end
