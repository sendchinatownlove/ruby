class ChangeFeeDescriptionToName < ActiveRecord::Migration[6.0]
  def change
    rename_column :fees, :description, :name
  end
end
