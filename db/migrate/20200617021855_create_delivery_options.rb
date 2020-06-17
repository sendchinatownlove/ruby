class CreateDeliveryOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :delivery_options do |t|
      t.string :url
      t.string :phone_number
      t.references :seller, null: false, foreign_key: true

      t.timestamps
    end
  end
end
