# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    address1 { Faker::Address.street_address }
    address2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    phone_number { Faker::PhoneNumber.cell_phone }
    zip_code { Faker::Address.zip_code }
  end
end
