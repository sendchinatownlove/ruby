# frozen_string_literal: true

class CreateOpenHours < ActiveRecord::Migration[6.0]
  def change
    create_table :open_hours do |t|
      t.references :seller, null: false, foreign_key: true
      t.integer :day
      t.time :open
      t.time :close

      t.timestamps
    end
  end
end
