# frozen_string_literal: true

FactoryBot.define do
  factory :redemption do
    association :contact
    association :reward
  end
end
