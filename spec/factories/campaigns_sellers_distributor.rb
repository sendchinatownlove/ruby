# frozen_string_literal: true

FactoryBot.define do
  factory :campaigns_sellers_distributor do
    transient do
      with_seller_location { false }
    end
    association :campaign
    association :distributor
    association :seller, factory: :seller_with_location
  end
end
