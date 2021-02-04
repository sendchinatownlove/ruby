# frozen_string_literal: true

class AddNonSquarePaymentsToPaymentIntents < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_intents, :origin, :string, null: false, default: 'square'
    change_column :payment_intents, :square_payment_id, :string, null: true
    change_column :payment_intents, :square_location_id, :string, null: true
  end
end
