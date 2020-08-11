# frozen_string_literal: true

class ChangeOpenCloseHoursName < ActiveRecord::Migration[6.0]
  def change
    rename_column :open_hours, :openday, :open_day
    rename_column :open_hours, :closeday, :close_day
  end
end
