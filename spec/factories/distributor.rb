# frozen_string_literal: true

FactoryBot.define do
  factory :distributor do
    association :contact
  end
end
