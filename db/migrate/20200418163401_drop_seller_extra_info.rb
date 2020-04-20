class DropSellerExtraInfo < ActiveRecord::Migration[6.0]
  def change
  drop_table :seller_extra_infos
  end
end
