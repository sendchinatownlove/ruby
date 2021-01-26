# == Schema Information
#
# Table name: rewards
#
#  id          :bigint           not null, primary key
#  image_url   :string
#  name        :string
#  total_value :integer
#
class Reward < ApplicationRecord
    validates_presence_of :total_value
    validates_presence_of :name
    validates_presence_of :image_url
end
