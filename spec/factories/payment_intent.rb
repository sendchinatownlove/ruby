# frozen_string_literal: true

FactoryBot.define do
  factory :payment_intent do
    receipt_url { Faker::Lorem.word }
    successful { false }
    square_payment_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    square_location_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    association :recipient, factory: :contact
    association :purchaser, factory: :contact
  end
end
