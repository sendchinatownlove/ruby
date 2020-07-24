class CreateCampaigns < ActiveRecord::Migration[6.0]
  def change
    create_table :campaigns do |t|
      t.boolean :active, default: false
      t.boolean :valid, default: false
      t.datetime :end_date, null: false
      t.string :description, null: true
      t.string :gallery_image_urls, null: true, array: true

      t.references :location, null: false, foreign_key: true
      t.references :seller, null: false, foreign_key: true

      t.timestamps
    end
  end
end
