# frozen_string_literal: true

FactoryBot.define do
  factory :campaign do
    active { true }
    valid { true }
    end_date { Faker::Time.forward(days: 30) }
    association :location
    association :seller
  end
end
