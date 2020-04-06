class CreateGiftCards < ActiveRecord::Migration[6.0]
  def change
    create_table :gift_cards do |t|
      t.string :charge_id
      t.string :merchant_id
      t.string :customer_id
      t.integer :amount

      t.timestamps
    end
  end
end
