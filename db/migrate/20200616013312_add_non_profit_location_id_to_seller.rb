# frozen_string_literal: true

class AddNonProfitLocationIdToSeller < ActiveRecord::Migration[6.0]
  def change
    add_column :sellers, :non_profit_location_id, :string
  end
end
