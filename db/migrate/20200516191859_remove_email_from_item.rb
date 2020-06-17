# frozen_string_literal: true

class RemoveEmailFromItem < ActiveRecord::Migration[6.0]
  def change
    remove_column :items, :email, :string
  end
end
