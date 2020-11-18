# frozen_string_literal: true

class RemoveSellerIdFromFees < ActiveRecord::Migration[6.0]
  def change
    remove_column :fees, :seller_id
  end
end
