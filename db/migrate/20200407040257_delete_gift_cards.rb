# frozen_string_literal: true

class DeleteGiftCards < ActiveRecord::Migration[6.0]
  def change
    drop_table(:gift_cards)
  end
end
