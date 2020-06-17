# == Schema Information
#
# Table name: delivery_options
#
#  id           :bigint           not null, primary key
#  url          :string
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  seller_id    :bigint           not null
#
class DeliveryOption < ApplicationRecord
	belongs_to :seller
	has_one :delivery_type
end
