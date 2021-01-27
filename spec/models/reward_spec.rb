# frozen_string_literal: true

# == Schema Information
#
# Table name: rewards
#
#  id          :bigint           not null, primary key
#  image_url   :string
#  name        :string
#  total_value :integer
#
require 'rails_helper'

RSpec.describe Reward, type: :model do
  it { should validate_presence_of(:total_value) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:image_url) }
end
