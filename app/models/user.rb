# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  email         :string
#  is_subscribed :boolean
#
class User < ApplicationRecord
  validates_uniqueness_of :email, :allow_blank => true, :allow_nil => true
  validates_presence_of :is_subscribed
end
