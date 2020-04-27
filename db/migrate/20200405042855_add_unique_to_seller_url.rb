# frozen_string_literal: true

class AddUniqueToSellerUrl < ActiveRecord::Migration[6.0]
  def change
    change_column :sellers, :url, :string, unique: true
  end
end
