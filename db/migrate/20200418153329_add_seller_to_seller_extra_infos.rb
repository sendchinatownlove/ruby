class AddSellerToSellerExtraInfos < ActiveRecord::Migration[6.0]
  def change
    add_reference :seller_extra_infos, :seller, null: false, foreign_key: true
  end
end
