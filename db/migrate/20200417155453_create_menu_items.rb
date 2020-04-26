# frozen_string_literal: true

class CreateMenuItems < ActiveRecord::Migration[6.0]
  def change
    create_table :menu_items do |t|
      t.string :name
      t.string :description
      t.integer :amount
      t.string :image_url
      t.references :seller, null: false, foreign_key: true

      t.timestamps
    end
  end
end
