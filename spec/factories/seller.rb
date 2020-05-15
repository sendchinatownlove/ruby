# frozen_string_literal: true

FactoryBot.define do
  factory :seller do
    seller_id { Faker::Alphanumeric.alphanumeric(number: 64) }
    cuisine_name { Faker::Food.dish }

    name_en { 'en' + Faker::Movies::StarWars.planet }
    name_zh_cn { 'zh-CN' + Faker::Movies::StarWars.planet }
    story_en { 'en' + Faker::Movies::StarWars.wookiee_sentence }
    story_zh_cn { 'zh-CN' + Faker::Movies::StarWars.wookiee_sentence }
    summary_en { 'en' + Faker::Movies::StarWars.wookiee_sentence }
    summary_zh_cn { 'zh-CN' + Faker::Movies::StarWars.wookiee_sentence }
    owner_name_en { 'en' + Faker::Movies::StarWars.character }
    owner_name_zh_cn { 'zh-CN' + Faker::Movies::StarWars.character }

    owner_image_url { Faker::Lorem.word }
    hero_image_url { Faker::Alphanumeric.alphanumeric(number: 64) }
    progress_bar_color { Faker::Alphanumeric.alphanumeric(number: 64) }
    accept_donations { false }
    sell_gift_cards { Faker::Boolean.boolean }
    business_type { Faker::Company.type }
    num_employees { Faker::Number.digit }
    founded_year { Faker::Number.within(range: 1800..2020) }
    website_url { Faker::Lorem.word }
    menu_url { Faker::Lorem.word }
    square_location_id { Faker::Alphanumeric.alphanumeric(number: 64) }
  end
end
