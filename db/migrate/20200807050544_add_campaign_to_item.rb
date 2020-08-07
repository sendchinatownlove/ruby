class AddCampaignToItem < ActiveRecord::Migration[6.0]
  def change
    add_reference :items, :campaign, foreign_key: true
  end
end
