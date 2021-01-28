# frozen_string_literal: true

FactoryBot.define do
  factory :crawl_receipt do
    amount { 1000 }
    receipt_url { 'www.testreceipturl.com' }
    association :contact

    trait :with_redemption do
      association :redemption
    end

    trait :with_payment_intent do
      association :payment_intent
    end

    trait :with_participating_seller do
      association :participating_seller
    end
  end
end
