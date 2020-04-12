FactoryBot.define do
  factory :payment_intent do
    email { Faker::Internet.email }
    stripe_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    successful { false }
  end
end
