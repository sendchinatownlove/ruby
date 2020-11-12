class UniqueConstraintOnCampaignsSellersDistributors < ActiveRecord::Migration[6.0]
  def change
    add_index :campaigns_sellers_distributors, [:campaign_id, :distributor_id, :seller_id], :unique => true, :name => 'campaigns_sellers_distributors_unique'
  end
end
