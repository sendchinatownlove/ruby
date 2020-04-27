# frozen_string_literal: true

class ChangeDataTypeForMenuItem < ActiveRecord::Migration[6.0]
  def change
    change_column :menu_items, :amount, :numeric
  end
end
