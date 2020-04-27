# frozen_string_literal: true

class AddSquareLocationIDtoSeller < ActiveRecord::Migration[6.0]
  def change
    add_column :sellers, :square_location_id, :string
  end
end
