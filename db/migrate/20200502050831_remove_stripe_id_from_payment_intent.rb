# frozen_string_literal: true

class RemoveStripeIdFromPaymentIntent < ActiveRecord::Migration[6.0]
  def change
    remove_column :payment_intents, :stripe_id, :string
  end
end
