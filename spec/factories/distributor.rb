# frozen_string_literal: true

FactoryBot.define do
  factory :distributor do
    association :contact
    image_url { Faker::Alphanumeric.alphanumeric(number: 64) }
    website_url { Faker::Alphanumeric.alphanumeric(number: 64) }
    name { Faker::name }
  end
end
