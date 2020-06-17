class DeliveryOption < ApplicationRecord
	belongs_to :seller
	has_one :delivery_type
end
