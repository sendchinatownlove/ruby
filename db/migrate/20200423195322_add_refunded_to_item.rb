class AddRefundedToItem < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :refunded, :boolean, default: false
  end
end
