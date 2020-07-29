class ChangeOpenClose < ActiveRecord::Migration[6.0]
  def change
    rename_column :open_hours, :open, :open_time
    rename_column :open_hours, :close, :close_time
  end
end
