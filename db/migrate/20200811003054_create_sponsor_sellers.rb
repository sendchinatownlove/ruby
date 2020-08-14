class CreateSponsorSellers < ActiveRecord::Migration[6.0]
  def change
    create_table :sponsor_sellers do |t|
      t.string :name
      t.bigint :location_id
      t.string :logo_url
      t.string :reward
      t.integer :reward_cost

      t.timestamps
    end
  end
end
