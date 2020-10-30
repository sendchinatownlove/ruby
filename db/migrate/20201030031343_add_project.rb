class AddProject < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :square_location_id, null: false

      t.timestamps
    end
  end
end
