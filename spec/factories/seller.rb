
FactoryBot.define do
  factory :seller do
    seller_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    cuisine_name { Faker::Food.dish }
    name { Faker::Movies::StarWars.planet }
    story { Faker::Movies::StarWars.wookiee_sentence }
    owner_name { Faker::Movies::StarWars.character }
    owner_image_url { Faker::Lorem.word }
    hero_image_url { Faker::Alphanumeric.alphanumeric(number: 64) }
    progress_bar_color { Faker::Alphanumeric.alphanumeric(number: 64) }
    accept_donations { Faker::Boolean.boolean }
    sell_gift_cards { Faker::Boolean.boolean }
    business_type { Faker::Company.type }
    num_employees { Faker::Number.digit }
    founded_year { Faker::Number.within(range: 1800..2020) }
    website_url { Faker::Lorem.word }
    menu_url { Faker::Lorem.word }
  end
end
