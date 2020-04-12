class CreatePaymentIntents < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_intents do |t|
      t.string :stripe_id
      t.string :email
      t.text :line_items

      t.timestamps
    end
  end
end
