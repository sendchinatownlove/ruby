# frozen_string_literal: true

class CreateAddress < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.string :address1, null: false
      t.string :address2
      t.string :city, null: false
      t.string :state, length: 2, null: false
      t.string :zip_code, null: false
      t.references :seller, null: false, foreign_key: true

      t.timestamps
    end
  end
end
