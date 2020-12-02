class ChangeFeeFlatCostToInteger < ActiveRecord::Migration[6.0]
  def change
    change_column :fees, :flat_cost, :integer, default: 0
  end
end
