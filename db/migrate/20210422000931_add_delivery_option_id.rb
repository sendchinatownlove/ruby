class AddDeliveryOptionId < ActiveRecord::Migration[6.0]
  def change
    add_column :delivery_types, :delivery_type_id, :string
  end
end
