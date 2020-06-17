# == Schema Information
#
# Table name: delivery_types
#
#  id                  :bigint           not null, primary key
#  name                :string           not null
#  icon_url            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  delivery_options_id :bigint
#
class DeliveryType < ApplicationRecord
	validates_presence_of :name
	validates_uniqueness_of :name
end
