# frozen_string_literal: true

class ChangeDateTimeToDateInGiftCardDetail < ActiveRecord::Migration[6.0]
  def change
    change_column :gift_card_details, :expiration, :date
  end
end
