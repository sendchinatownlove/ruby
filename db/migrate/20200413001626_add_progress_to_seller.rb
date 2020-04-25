# frozen_string_literal: true

class AddProgressToSeller < ActiveRecord::Migration[6.0]
  def change
    # amount in cents
    add_column :sellers, :target_amount, :integer, default: 1_000_000
  end
end
