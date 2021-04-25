# frozen_string_literal: true

FactoryBot.define do
  factory :delivery_type do
    name { "Phone" }
    delivery_type_id { Faker::Lorem.word}
  end
end
