# frozen_string_literal: true

FactoryBot.define do
  factory :existing_event do
    idempotency_key { Faker::Alphanumeric.alphanumeric(number: 64) }

    trait :charge do
      event_type { :charges_create }
    end

    trait :webhook do
      event_type { :payment_updated }
    end
  end
end
