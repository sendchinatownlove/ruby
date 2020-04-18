class CreateSellerExtraInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :seller_extra_infos do |t|
      t.string :type # e.g. "Family-owned and operated"
      t.integer :num_employees
      t.integer :founded_year
      t.string :website_url
      t.string :menu_url

      t.timestamps
    end
  end
end
