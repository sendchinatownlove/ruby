# frozen_string_literal: true

FactoryBot.define do
  factory :campaign do
    active { :active }
    valid { true }
    end_date { Faker::Time.forward(days: 30) }
    association :location
    association :seller
    association :distributor

    trait :with_sellers_distributors do
      after(:create) do |campaign, index|
        FactoryBot.create :campaigns_sellers_distributor, campaign_id: campaign.id
        FactoryBot.create :campaigns_sellers_distributor, campaign_id: campaign.id
      end
    end
  end
end
