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
require 'rails_helper'

RSpec.describe Project, type: :model do
  it { should validate_presence_of(:square_location_id) }
end
