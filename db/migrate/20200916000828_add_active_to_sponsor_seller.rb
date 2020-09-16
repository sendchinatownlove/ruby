class AddActiveToSponsorSeller < ActiveRecord::Migration[6.0]
  def change
    add_column :sponsor_sellers, :active, :boolean, default: true
    change_column_null :sponsor_sellers, :active, false, true
  end
end
