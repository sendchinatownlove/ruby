# frozen_string_literal: true

FactoryBot.define do
  factory :payment_intent do
    receipt_url { Faker::Lorem.word }
    successful { false }
    square_payment_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    square_location_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    association :recipient, factory: :contact
    association :purchaser, factory: :contact
  end

  trait :with_campaign do
    association :campaign
  end

  trait :with_project do
    association :project
  end

  trait :with_line_items do
    line_items do
      %(
        [
          {"amount": 100, "seller_id": "42", "item_type": "donation"},
          {"amount": 200, "seller_id": "42", "item_type": "donation"},
          {"amount": 300, "seller_id": "43", "item_type": "donation"}
        ]
      )
    end
  end

  trait :with_transaction_fee do
    line_items do
      %(
        [
          {"amount": 1000, "seller_id": "43", "item_type": "donation"},
          {"amount": 314, "seller_id": "43", "item_type": "transaction_fee"}
        ]
      )
    end
  end
end
