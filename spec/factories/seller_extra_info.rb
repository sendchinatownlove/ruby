FactoryBot.define do
  factory :seller_extra_info do
    association :seller
    type { Faker::Company.type }
    num_employees { Faker::Alphanumeric.alphanumeric(number: 64) }
    founded_year { Faker::Alphanumeric.alphanumeric(number: 64) }
    website_url { Faker::Lorem.word }
    menu_url { Faker::Lorem.word }
  end
end
