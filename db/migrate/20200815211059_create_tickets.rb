# frozen_string_literal: true

class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.references :contact, null: false, foreign_key: true
      t.string :ticket_id, null: false
      t.references :participating_seller, null: false, foreign_key: true
      t.references :sponsor_seller, null: true, foreign_key: true
      t.date :redeemed_at
      t.date :expiration

      t.timestamps
    end
  end
end
