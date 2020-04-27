# frozen_string_literal: true

class UpdateSellerGiftCardsDonationsDefault < ActiveRecord::Migration[6.0]
  def change
    change_column(
      :sellers,
      :sell_gift_cards,
      :boolean,
      null: false,
      default: false
    )
    change_column(
      :sellers,
      :accept_donations,
      :boolean,
      null: false,
      default: true
    )
  end
end
