# frozen_string_literal: true

FactoryBot.define do
  factory :lyft_reward do
    state { 'new' }
    token { Faker::Alphanumeric.alphanumeric(number: 64) }
    code { Faker::Alphanumeric.alphanumeric(number: 64) }
    expires_at { Time.now + 30.minutes }

    association :contact
  end
end
