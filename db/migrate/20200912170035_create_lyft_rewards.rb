# frozen_string_literal: true

class CreateLyftRewards < ActiveRecord::Migration[6.0]
  def change
    create_table :lyft_rewards do |t|
      t.string :code, null: false
      t.string :state, null: false, default: 'new'
      t.string :token
      t.date :expires_at

      t.references :contact, null: true, foreign_key: true

      t.timestamps
    end
  end
end
