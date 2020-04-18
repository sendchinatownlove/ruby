class AddSquareColumnToPaymentIntent < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_intents, :square_payment_id, :string
  end
end
