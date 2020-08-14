# frozen_string_literal: true

# == Schema Information
#
# Table name: locations
#
#  id           :bigint           not null, primary key
#  address1     :string           not null
#  address2     :string
#  city         :string           not null
#  neighborhood :string
#  phone_number :string
#  state        :string           not null
#  zip_code     :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  seller_id    :bigint
#
# Indexes
#
#  index_locations_on_seller_id  (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (seller_id => sellers.id)
#
class Location < ApplicationRecord
  # validations
  validates_presence_of :city, :state, :address1, :zip_code
end
