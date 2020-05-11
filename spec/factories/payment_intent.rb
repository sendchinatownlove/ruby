# frozen_string_literal: true

FactoryBot.define do
  factory :payment_intent do
    email { Faker::Internet.email }
    receipt_url { Faker::Lorem.word }
    name { Faker::Superhero.name }
    email_text { Faker::Superhero.power }
    successful { false }
    square_payment_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    square_location_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    association :recipient, factory: :contact
    association :purchaser, factory: :contact
  end
end
