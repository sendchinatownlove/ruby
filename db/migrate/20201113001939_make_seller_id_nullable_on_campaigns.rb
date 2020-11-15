class MakeSellerIdNullableOnCampaigns < ActiveRecord::Migration[6.0]
  def change
    change_column :campaigns, :seller_id, :bigint, null: true
  end
end
