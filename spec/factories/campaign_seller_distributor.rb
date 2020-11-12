# frozen_string_literal: true

FactoryBot.define do
    factory :campaign_seller_distributor do
        association :campaign
        association :distributor
        association :seller
    end
end
