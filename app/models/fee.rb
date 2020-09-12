# frozen_string_literal: true

# == Schema Information
#
# Table name: fees
#
#  id                  :bigint           not null, primary key
#  active              :boolean          default(TRUE)
#  covered_by_customer :boolean
#  description         :string
#  flat_cost           :decimal(8, 2)    default(0.0)
#  multiplier          :decimal(, )      default(0.0)
#
class Fee < ApplicationRecord
  has_and_belongs_to_many :campaigns
end
