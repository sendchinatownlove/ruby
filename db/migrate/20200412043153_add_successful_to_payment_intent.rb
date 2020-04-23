class AddSuccessfulToPaymentIntent < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_intents, :successful, :boolean, default: false
  end
end
