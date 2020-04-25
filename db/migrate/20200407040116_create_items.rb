# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.string :stripe_customer_id
      t.references :seller, null: false, foreign_key: true
      t.integer :item_type

      t.timestamps
    end
  end
end
