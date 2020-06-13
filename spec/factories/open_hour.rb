# frozen_string_literal: true

FactoryBot.define do
  factory :open_hour do
    sequence(:openday, (0..6).cycle) { |n| n.to_s.to_i }
    closeday { openday.to_s.to_i }
    open { Faker::Time.between_dates(from: Date.today, to: Date.today, period: :morning, format: :short) }
    close { Faker::Time.between_dates(from: Date.today, to: Date.today, period: :evening, format: :short) }

    association :seller
  end
end
