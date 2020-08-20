# frozen_string_literal: true

FactoryBot.define do
  factory :ticket do
    redeemed_at do
      Faker::Date.between(
        from: Date.today - 30.days,
        to: Date.today - 1.days
      )
    end

    expiration do
      Faker::Date.between(
        from: Date.today + 1.days,
        to: Date.today + 100.days
      )
    end
    association :contact
    association :participating_seller
    association :sponsor_seller
  end
end
