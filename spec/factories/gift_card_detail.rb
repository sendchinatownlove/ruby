FactoryBot.define do
  factory :gift_card_detail do
    gift_card_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    receipt_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    expiration { Time.at(rand_in_range(Time.current.to_f, 1.year.from_now)) }
    association :gift_card_amount
  end
end
