class ChangeColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :items, :stripe_customer_id, :email
  end
end
