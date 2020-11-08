# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id                 :bigint           not null, primary key
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  square_location_id :string           not null
#
class Project < ApplicationRecord
  validates_presence_of :square_location_id
end
