# frozen_string_literal: true

class AddNameToPaymentIntents < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_intents, :name, :string
  end
end
