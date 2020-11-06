# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  it { should validate_presence_of(:square_location_id) }
end
