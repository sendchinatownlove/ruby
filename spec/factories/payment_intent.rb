FactoryBot.define do
  factory :payment_intent do
    email { Faker::Internet.email }
    stripe_id { Faker::Alphanumeric.alphanumeric(number: 64) unless ENV['USE_SQUARE'] == 'true' }
    square_payment_id { Faker::Alphanumeric.alphanumeric(number: 64) if ENV['USE_SQUARE'] == 'true' }
    square_location_id { Faker::Alphanumeric.alphanumeric(number: 64) if ENV['USE_SQUARE'] == 'true' }
    receipt_url { Faker::Lorem.word }
    name { Faker::Superhero.name }
    email_text { Faker::Superhero.power }
    successful { false }
  end
end
