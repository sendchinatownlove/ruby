# frozen_string_literal: true

class AddLockVersionToPaymentIntents < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_intents, :lock_version, :integer
  end
end
