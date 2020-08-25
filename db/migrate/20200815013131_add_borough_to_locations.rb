# frozen_string_literal: true

class AddBoroughToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :borough, :string
  end
end
