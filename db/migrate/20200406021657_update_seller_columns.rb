# frozen_string_literal: true

class UpdateSellerColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :sellers, :merchant_name, :name
    rename_column :sellers, :url, :seller_id
  end
end
