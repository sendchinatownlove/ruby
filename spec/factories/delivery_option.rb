# frozen_string_literal: true

FactoryBot.define do
  factory :delivery_option do
    association :seller

    trait :with_delivery_type do
      after(:create) do |d, i|
        FactoryBot.create :delivery_type, delivery_option_id: d.id, name: i
      end
    end
  end
end
