# frozen_string_literal: true

# Add up down in case we want to rollback the migration
class ChangePaymentIntentSquareTypes < ActiveRecord::Migration[6.0]
  def up
    change_column :payment_intents, :square_payment_id, :string, null: false
    change_column :payment_intents, :square_location_id, :string, null: false
  end

  def down
    change_column :payment_intents, :square_payment_id, :string, null: true
    change_column :payment_intents, :square_location_id, :string, null: true
  end
end
