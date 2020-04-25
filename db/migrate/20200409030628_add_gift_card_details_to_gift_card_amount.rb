# frozen_string_literal: true

class AddGiftCardDetailsToGiftCardAmount < ActiveRecord::Migration[6.0]
  def change
    add_reference :gift_card_amounts, :gift_card_details, null: false, foreign_key: true
  end
end
