# frozen_string_literal: true

# == Schema Information
#
# Table name: locations
#
#  id           :bigint           not null, primary key
#  address1     :string           not null
#  address2     :string
#  city         :string           not null
#  state        :string           not null
#  zip_code     :string           not null
#  seller_id    :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  phone_number :string
#
class Location < ApplicationRecord
  # validations
  validates_presence_of :city, :state, :address1, :zip_code
end
