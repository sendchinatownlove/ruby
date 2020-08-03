class MakeSellerNullableOnLocation < ActiveRecord::Migration[6.0]
  def change
    change_column :locations, :seller_id, :bigint, null: true
  end
end
