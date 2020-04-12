FactoryBot.define do
  factory :gift_card_detail do
    gift_card_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    seller_gift_card_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    receipt_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    expiration { Faker::Date.between(from: 2.days.ago, to: Date.today) }
    association :item
  end
end
