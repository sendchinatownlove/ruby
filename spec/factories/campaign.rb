# frozen_string_literal: true

FactoryBot.define do
  factory :campaign do
    active { true }
    valid { true }
    end_date { DateTime.now }
    association :location
    association :seller
  end
end
