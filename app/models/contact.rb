# == Schema Information
#
# Table name: contacts
#
#  id            :bigint           not null, primary key
#  email         :string
#  is_subscribed :boolean          default(TRUE), not null
#  name          :string
#
# Indexes
#
#  index_users_on_email  (email)
#
class Contact < ApplicationRecord
  validates_uniqueness_of :email, :allow_blank => true, :allow_nil => true
  validates :is_subscribed, inclusion: { in: [ true, false ] }
end
