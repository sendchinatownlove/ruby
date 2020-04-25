class AddReceiptUrlToPaymentIntents < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_intents, :receipt_url, :string
  end
end
