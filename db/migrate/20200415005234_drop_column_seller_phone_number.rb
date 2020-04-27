# frozen_string_literal: true

class DropColumnSellerPhoneNumber < ActiveRecord::Migration[6.0]
  def change
    remove_column :sellers, :phone_number
  end
end
