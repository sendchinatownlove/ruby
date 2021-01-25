class CreateRewards < ActiveRecord::Migration[6.0]
  def change
    create_table :rewards do |t|
      t.integer :total_value
      t.string :name
      t.string :image_url

      t.timestamps
    end
  end
end
