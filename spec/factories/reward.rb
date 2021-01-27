# frozen_string_literal: true

FactoryBot.define do
  factory :reward do
    total_value { 1000 }
    image_url { 'www.testimageurl.com' }
    name { 'reward' }
  end
end
