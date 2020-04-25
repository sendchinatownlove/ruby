# frozen_string_literal: true

class CreateDonationDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :donation_details do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :amount

      t.timestamps
    end
  end
end
