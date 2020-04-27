# frozen_string_literal: true

class UpdateSellerUrlNonNull < ActiveRecord::Migration[6.0]
  def change
    change_column :sellers, :url, :string, null: false
  end
end
