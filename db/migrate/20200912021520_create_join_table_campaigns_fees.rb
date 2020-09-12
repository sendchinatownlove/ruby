class CreateJoinTableCampaignsFees < ActiveRecord::Migration[6.0]
  def change
    create_join_table :campaigns, :fees do |t|
      # t.index [:campaign_id, :fee_id]
      # t.index [:fee_id, :campaign_id]
    end

    add_column :campaigns, :has_square_fee, :boolean, default: true
  end
end
