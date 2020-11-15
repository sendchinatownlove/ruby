# frozen_string_literal: true

FactoryBot.define do
    factory :campaigns_sellers_distributor do
      association :campaign
      association :distributor
      association :seller
    end
  end
