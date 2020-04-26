# frozen_string_literal: true

class AddIndexToSellerUrl < ActiveRecord::Migration[6.0]
  def change
    add_index :sellers, :url
  end
end
