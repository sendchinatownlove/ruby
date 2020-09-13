# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    is_subscribed { Faker::Boolean }
    rewards_redemption_access_token { Faker::Alphanumeric.alphanumeric(number: 64) }
    expires_at { Time.now + 30.minutes }
  end
end
