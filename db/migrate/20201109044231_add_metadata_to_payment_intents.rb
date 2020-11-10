# frozen_string_literal: true

class AddMetadataToPaymentIntents < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_intents, :metadata, :text
  end
end
