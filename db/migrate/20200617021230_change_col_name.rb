class ChangeColName < ActiveRecord::Migration[6.0]
  def change
  	rename_column :delivery_types, :icon, :icon_url
  end
end
