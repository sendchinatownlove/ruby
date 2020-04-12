
FactoryBot.define do
  factory :seller do
    seller_id { Faker::Lorem.word }
    cuisine_name { Faker::Food.dish }
    name { Faker::Movies::StarWars.planet }
    story { Faker::Movies::StarWars.wookiee_sentence }
    owner_name { Faker::Movies::StarWars.character }
    owner_image_url { Faker::Lorem.word }
    accept_donations { Faker::Boolean.boolean }
    sell_gift_cards { Faker::Boolean.boolean }
  end
end
