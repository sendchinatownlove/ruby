# frozen_string_literal: true

class AddPaymentIntentNullableToItems < ActiveRecord::Migration[6.0]
  def change
    change_column_null :items, :payment_intent_id, true
  end
end
