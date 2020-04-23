FactoryBot.define do
  factory :menu_item do
    name { Faker::Movies::StarWars.planet }
    description { Faker::Movies::StarWars.wookiee_sentence }
    amount { Faker::Number.number(digits: 3) }
    image_url { Faker::Lorem.word }
    association :seller
  end
end
