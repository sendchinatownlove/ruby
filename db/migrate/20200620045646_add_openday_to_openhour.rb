# frozen_string_literal: true

class AddOpendayToOpenhour < ActiveRecord::Migration[6.0]
  def change
    add_column :open_hours, :openday, :integer
  end
end
