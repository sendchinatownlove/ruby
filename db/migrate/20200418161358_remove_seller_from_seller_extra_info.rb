class RemoveSellerFromSellerExtraInfo < ActiveRecord::Migration[6.0]
  def change
    remove_reference :seller_extra_infos, :seller, null: false, foreign_key: true
  end
end
