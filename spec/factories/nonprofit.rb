# frozen_string_literal: true

FactoryBot.define do
  factory :nonprofit do
    name { Faker.name }
    logo_image_url { Faker::Alphanumeric.alphanumeric(number: 64) }
    contact_id { rand(3) }
    fee_id { rand(3) }
  end
end
