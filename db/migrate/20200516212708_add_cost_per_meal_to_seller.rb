class AddCostPerMealToSeller < ActiveRecord::Migration[6.0]
  def change
    add_column :sellers, :cost_per_meal, :integer
  end
end
