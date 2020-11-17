# frozen_string_literal: true

# == Schema Information
#
# Table name: fees
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE)
#  flat_cost  :decimal(8, 2)    default(0.0)
#  multiplier :decimal(6, 4)    default(0.0)
#  name       :string
#
require 'rails_helper'

RSpec.describe Fee, type: :model do
  # Association test
  it { should have_and_belong_to_many(:campaigns) }
end
