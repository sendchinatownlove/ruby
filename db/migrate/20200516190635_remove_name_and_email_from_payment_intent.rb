# frozen_string_literal: true

class RemoveNameAndEmailFromPaymentIntent < ActiveRecord::Migration[6.0]
  def change
    remove_column :payment_intents, :email, :string
    remove_column :payment_intents, :email_text, :string
    remove_column :payment_intents, :name, :string
  end
end
