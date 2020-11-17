class AddStartDateToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :start_date, :datetime, null: true
  end
end
