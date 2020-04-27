# frozen_string_literal: true

class AddColumnsToSeller < ActiveRecord::Migration[6.0]
  def change
    add_column :sellers, :type, :string # e.g. "Family-owned and operated"
    add_column :sellers, :num_employees, :integer
    add_column :sellers, :founded_year, :integer
    add_column :sellers, :website_url, :string
    add_column :sellers, :menu_url, :string
  end
end
