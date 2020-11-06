# frozen_string_literal: true

class Project < ApplicationRecord
  validates_presence_of :square_location_id
end
