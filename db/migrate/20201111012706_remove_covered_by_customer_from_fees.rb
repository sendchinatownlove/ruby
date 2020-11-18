# frozen_string_literal: true

class RemoveCoveredByCustomerFromFees < ActiveRecord::Migration[6.0]
  def change
    remove_column :fees, :covered_by_customer
  end
end
