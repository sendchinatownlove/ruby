FactoryBot.define do
  factory :payment_intent do
    email { Faker::Internet.email }
    stripe_id { Faker::Alphanumeric.alphanumeric(number: 64) if ENV['USE_STRIPE'].present? }
    square_payment_id { Faker::Alphanumeric.alphanumeric(number: 64) if ENV['USE_SQUARE'].present? }
    successful { false }
  end
end
