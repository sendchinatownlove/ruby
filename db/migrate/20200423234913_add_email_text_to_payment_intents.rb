class AddEmailTextToPaymentIntents < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_intents, :email_text, :string
  end
end
