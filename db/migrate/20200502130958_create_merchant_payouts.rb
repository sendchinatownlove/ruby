class CreateMerchantPayouts < ActiveRecord::Migration[6.0]
  def change
    create_table :merchant_payouts do |t|
      t.integer :payout_type, default: 0, null:false
      t.integer :total_amount, null: false
      t.integer :account_number, null: false
      t.date :payment_delivered

      # for check payments
      t.integer :check_number
      t.date :payment_cashed

      # for cash payments
      t.date :cash_withdrawn

      t.references :seller, null: false, foreign_key: true

      t.timestamps
    end
  end
end
