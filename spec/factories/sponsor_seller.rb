# frozen_string_literal: true

FactoryBot.define do
  factory :sponsor_seller do
    name { Faker::Restaurant.name }
    association :location
    logo_url { 'https://example.com/placeholder.jpg' }
    reward { Faker::Movies::StarWars.planet }
    reward_cost { rand(10) }
  end
end
