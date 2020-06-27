# frozen_string_literal: true

class RemoveDayFromOpenhour < ActiveRecord::Migration[6.0]
  def change
    remove_column :open_hours, :day, :integer
  end
end
