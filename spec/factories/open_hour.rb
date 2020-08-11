# frozen_string_literal: true

FactoryBot.define do
  factory :open_hour do
    sequence(:open_day, (0..6).cycle) { |n| n.to_s.to_i }
    close_day { open_day.to_s.to_i }
    open_time { Faker::Time.between_dates(from: Date.today, to: Date.today, period: :morning, format: :short) }
    close_time { Faker::Time.between_dates(from: Date.today, to: Date.today, period: :evening, format: :short) }

    association :seller
  end
end
