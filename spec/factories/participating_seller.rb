# frozen_string_literal: true

FactoryBot.define do
  factory :participating_seller do
    name { Faker::Restaurant.name }
    seller_id { rand(3) }
    stamp_url { 'https://example.com/placeholder.jpg' }
    tickets_secret { Faker::Internet.uuid }
  end
end
