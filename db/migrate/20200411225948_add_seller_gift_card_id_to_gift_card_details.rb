# frozen_string_literal: true

class AddSellerGiftCardIdToGiftCardDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :gift_card_details, :seller_gift_card_id, :string
  end
end
