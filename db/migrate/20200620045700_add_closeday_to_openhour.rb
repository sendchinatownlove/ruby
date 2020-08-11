# frozen_string_literal: true

class AddClosedayToOpenhour < ActiveRecord::Migration[6.0]
  def change
    add_column :open_hours, :closeday, :integer
  end
end
