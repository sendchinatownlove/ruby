class CreateParticipatingSellers < ActiveRecord::Migration[6.0]
  def change
    create_table :participating_sellers do |t|
      t.string :name
      t.bigint :seller_id, null: true
      t.string :stamp_url
      t.string :tickets_secret, null: true, unique: true

      t.timestamps
    end
  end
end
