class CreateNonprofits < ActiveRecord::Migration[6.0]
  def change
    create_table :nonprofits do |t|
      t.string :name
      t.string :logo_image_url
      t.integer :contact_id
      t.integer :fee_id

      t.timestamps
    end
  end
end
