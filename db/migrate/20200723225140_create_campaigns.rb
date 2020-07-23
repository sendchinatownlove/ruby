class CreateCampaigns < ActiveRecord::Migration[6.0]
  def change
    create_table :campaigns do |t|
      t.boolean :active, default: false
      t.boolean :is_valid, default: false
      t.datetime :end_date, null: false
      t.string :description, null: false
      t.string :gallery_image_urls, default: [], null: false, array: true

      t.references :location, null: false, foreign_key: true
      t.references :seller, null: false, foreign_key: true

      t.timestamps
    end
  end
end
