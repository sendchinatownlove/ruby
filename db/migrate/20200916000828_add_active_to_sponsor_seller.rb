class AddActiveToSponsorSeller < ActiveRecord::Migration[6.0]
  def change
    add_column :sponsor_sellers, :active, :boolean
  end
end
