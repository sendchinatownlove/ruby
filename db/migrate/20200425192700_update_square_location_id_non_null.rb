class UpdateSquareLocationIdNonNull < ActiveRecord::Migration[6.0]
  def change
    change_column :sellers, :square_location_id, :string, null: false
  end
end
