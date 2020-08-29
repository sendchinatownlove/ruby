class AddExpiresAtToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :expires_at, :datetime
  end
end
