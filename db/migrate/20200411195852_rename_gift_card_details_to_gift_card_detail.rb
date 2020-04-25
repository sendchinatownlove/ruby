# frozen_string_literal: true

class RenameGiftCardDetailsToGiftCardDetail < ActiveRecord::Migration[6.0]
  def change
    rename_column :gift_card_amounts, :gift_card_details_id, :gift_card_detail_id
  end
end
