# frozen_string_literal: true

FactoryBot.define do
  factory :existing_event do
    idempotent_key { Faker::Alphanumeric.alphanumeric(number: 64) }

    trait :charge do
      type { :charges_create }
    end

    trait :webhook do
      type { :webhooks_create_refund_updated }
    end
  end
end
