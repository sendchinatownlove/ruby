# frozen_string_literal: true

FactoryBot.define do
  factory :delivery_type do
    name { Faker::Lorem.word }
  end
end
