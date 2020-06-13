# frozen_string_literal: true

class AddSingleUseToGiftCardDetail < ActiveRecord::Migration[6.0]
  def change
    add_column :gift_card_details, :single_use, :boolean, default: false, null: false
  end
end
