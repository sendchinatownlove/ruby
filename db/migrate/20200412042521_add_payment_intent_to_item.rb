# frozen_string_literal: true

class AddPaymentIntentToItem < ActiveRecord::Migration[6.0]
  def change
    add_reference :items, :payment_intent, null: false, foreign_key: true
  end
end
