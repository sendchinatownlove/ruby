class AddFlatCostToFee < ActiveRecord::Migration[6.0]
  def change
    add_column :fees, :flat_cost, :decimal, :precision => 8, :scale => 2, :default => 0.00
    add_column :fees, :covered_by_customer, :boolean
  end
end
