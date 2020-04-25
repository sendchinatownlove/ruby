# frozen_string_literal: true

class CreateGiftCardAmounts < ActiveRecord::Migration[6.0]
  def change
    create_table :gift_card_amounts do |t|
      t.integer :value

      t.timestamps
    end
  end
end
