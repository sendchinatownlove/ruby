class CreateGiftCardDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :gift_card_details do |t|
      t.string :gift_card_id
      t.string :receipt_id
      t.datetime :expiration

      t.timestamps
    end
  end
end
