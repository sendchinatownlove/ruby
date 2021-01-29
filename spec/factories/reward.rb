# frozen_string_literal: true

FactoryBot.define do
  factory :reward do
    image_url { Faker::Internet.url }
    name { Faker::Movies::StarWars.planet }
    total_value { Faker::Number.number(digits: 5) }
  end
end
