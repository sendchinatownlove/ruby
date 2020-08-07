class AddNameToDistributors < ActiveRecord::Migration[6.0]
  def change
    add_column :distributors, :name, :string
  end
end
