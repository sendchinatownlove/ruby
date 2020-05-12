class RenameUserToContact < ActiveRecord::Migration[6.0]
  def change
    rename_table :users, :contacts
  end
end
