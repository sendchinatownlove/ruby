# frozen_string_literal: true

# == Schema Information
#
# Table name: fees
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE)
#  flat_cost  :integer          default(0)
#  multiplier :decimal(6, 4)    default(0.0)
#  name       :string
#
class Fee < ApplicationRecord
  has_and_belongs_to_many :campaigns
end
