# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    is_subscribed { Faker::Boolean }
  end
end
