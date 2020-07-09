# frozen_string_literal: true

class AddSellerToFee < ActiveRecord::Migration[6.0]
  def change
    add_reference :fees, :seller, null: false
  end
end
