# frozen_string_literal: true

# == Schema Information
#
# Table name: rewards
#
#  id          :bigint           not null, primary key
#  image_url   :string
#  name        :string
#  total_value :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Reward < ApplicationRecord
  validates_presence_of :image_url
  validates_presence_of :name
  validates_presence_of :total_value

  has_many :redemptions, dependent: :destroy
end
