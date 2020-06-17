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

  trait :with_line_items do
    line_items {
      %{
        [
          {"amount": "100", "seller_id": "42", "item_type": "donation"},
          {"amount": "200", "seller_id": "42", "item_type": "donation"},
          {"amount": "300", "seller_id": "43", "item_type": "donation"}
        ]
      }
    }
  end
end
