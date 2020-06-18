class AddDeliveryTypeKeyToDeliveryOption < ActiveRecord::Migration[6.0]
  def change
  	# This should have been :delivery_option
  	add_reference :delivery_types, :delivery_option, index:true
  end
end
