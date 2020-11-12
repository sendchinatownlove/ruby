class CreateCampaignsSellersDistributors < ActiveRecord::Migration[6.0]
  def change
    create_table :campaigns_sellers_distributors do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :seller, null: false, foreign_key: true
      t.references :distributor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
