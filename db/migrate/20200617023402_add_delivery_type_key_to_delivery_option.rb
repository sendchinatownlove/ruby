class AddDeliveryTypeKeyToDeliveryOption < ActiveRecord::Migration[6.0]
  def change
  	add_reference :delivery_types, :delivery_options, index:true
  end
end
