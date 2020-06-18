class AddDeliveryTypeKeyToDeliveryOption < ActiveRecord::Migration[6.0]
  def change
  	# This should have been :delivery_option
  	add_reference :delivery_types, :delivery_options, index:true
  end
end
