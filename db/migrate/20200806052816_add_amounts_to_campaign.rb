class AddAmountsToCampaign < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :target_amount, :integer, default: 100000, null: false
    add_column :campaigns, :price_per_meal, :integer, default: 500, null: false
  end
end
