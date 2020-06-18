# == Schema Information
#
# Table name: delivery_options
#
#  id           :bigint           not null, primary key
#  phone_number :string
#  url          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  seller_id    :bigint           not null
#
# Indexes
#
#  index_delivery_options_on_seller_id  (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (seller_id => sellers.id)
#
class DeliveryOption < ApplicationRecord
	belongs_to :seller
	has_one :delivery_type
end
