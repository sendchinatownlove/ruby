# frozen_string_literal: true

class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.references :contact, null: true, foreign_key: true
      t.string :ticket_id
      t.references :participating_seller, references: :sellers, null: false, foreign_key: { to_table: :sellers}
      t.references :sponsor_seller, references: :sellers, null: true, foreign_key: { to_table: :sellers}
      t.date :redeemed_at
      t.date :expiration

      t.timestamps
    end
  end
end
