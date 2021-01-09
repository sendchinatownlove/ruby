class CreateCrawlReceipts < ActiveRecord::Migration[6.0]
  def change
    create_table :crawl_receipts do |t|
      t.references :participating_seller, null: true, foreign_key: true
      t.references :payment_intent, null: true, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.integer :amount
      t.string :receipt_url
    end
  end
end
