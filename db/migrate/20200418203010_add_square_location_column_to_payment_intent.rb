class AddSquareLocationColumnToPaymentIntent < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_intents, :square_location_id, :string
  end
end
