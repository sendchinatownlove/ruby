class AddDescriptionToFee < ActiveRecord::Migration[6.0]
  def change
    add_column :fees, :description, :string
  end
end
