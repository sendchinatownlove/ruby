# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { Faker.name }
    square_location_id { Faker::Alphanumeric.alphanumeric(number: 64) }
  end
end
