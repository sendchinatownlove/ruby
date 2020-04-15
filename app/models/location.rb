class Location < ApplicationRecord
  # validations
  validates_presence_of :city, :state, :address1, :zip_code
end
