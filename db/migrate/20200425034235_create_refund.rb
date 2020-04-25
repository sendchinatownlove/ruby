class CreateRefund < ActiveRecord::Migration[6.0]
  def change
    create_table :refunds do |t|
      t.string :square_refund_id
      t.string :status
      t.references :payment_intent, null: false, foreign_key: true

      t.timestamps
    end
  end
end
