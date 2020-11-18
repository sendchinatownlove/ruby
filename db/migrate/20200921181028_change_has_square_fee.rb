# frozen_string_literal: true

class ChangeHasSquareFee < ActiveRecord::Migration[6.0]
  def change
    remove_column :campaigns, :has_square_fee
    add_column :campaigns, :fee_id, :integer
  end
end
