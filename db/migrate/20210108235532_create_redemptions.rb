# frozen_string_literal: true

class CreateRedemptions < ActiveRecord::Migration[6.0]
  def change
    create_table :redemptions do |t|
      t.references :reward, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
    end
  end
end
