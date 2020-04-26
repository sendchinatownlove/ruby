# frozen_string_literal: true

class AddItemToGiftCardDetails < ActiveRecord::Migration[6.0]
  def change
    add_reference :gift_card_details, :item, null: false, foreign_key: true
  end
end
