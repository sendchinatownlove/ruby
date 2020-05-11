# frozen_string_literal: true

FactoryBot.define do
  factory :gift_card_detail do
    gift_card_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    seller_gift_card_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    receipt_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    expiration do
      Faker::Date.between(
        from: Date.today + 1.days,
        to: Date.today + 100.days
      )
    end
    association :item
    association :recipient, factory: :contact
  end
end
