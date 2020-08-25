# frozen_string_literal: true

class AddFeeToPaymentIntent < ActiveRecord::Migration[6.0]
  def change
    add_reference :payment_intents, :fee
  end
end
