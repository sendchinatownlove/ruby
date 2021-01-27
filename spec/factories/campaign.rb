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
      after(:create) do |campaign, _index|
        FactoryBot.create :campaigns_sellers_distributor, campaign_id: campaign.id
        FactoryBot.create :campaigns_sellers_distributor, campaign_id: campaign.id
        unless campaign.seller.nil?
          create_list(:location, 1, seller_id: campaign.seller.id)
        end
      end
    end

    trait :with_project do
      association :project
    end
  end
end
