class DropColumnSellerPhoneNumber < ActiveRecord::Migration[6.0]
  def change
    remove_column :sellers, :phone_number
  end
end
