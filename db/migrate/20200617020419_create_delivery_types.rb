# frozen_string_literal: true

class CreateDeliveryTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :delivery_types do |t|
      t.string :name, null: false
      t.string :icon

      t.timestamps
    end
  end
end
