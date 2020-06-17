class AddReferencesToDeliveryOptions < ActiveRecord::Migration[6.0]
  def change
    add_reference :delivery_options, :seller, null: false, foreign_key: true
  end
end
