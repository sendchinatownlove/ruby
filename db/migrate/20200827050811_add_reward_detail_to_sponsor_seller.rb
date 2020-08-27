class AddRewardDetailToSponsorSeller < ActiveRecord::Migration[6.0]
  def change
    add_column :sponsor_sellers, :reward_detail, :string
  end
end
