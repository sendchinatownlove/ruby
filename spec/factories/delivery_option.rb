# frozen_string_literal: true

FactoryBot.define do
  factory :delivery_option do
    association :seller
  end
end