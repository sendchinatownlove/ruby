# frozen_string_literal: true

class CreateSellers < ActiveRecord::Migration[6.0]
  def change
    create_table :sellers do |t|
      t.string :url
      t.string :cuisine_name
      t.string :merchant_name
      t.string :story
      t.boolean :accept_donations
      t.boolean :sell_gift_cards
      t.string :owner_name
      t.string :owner_url

      t.timestamps
    end
  end
end
