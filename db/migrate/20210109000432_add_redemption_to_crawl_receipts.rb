# frozen_string_literal: true

class AddRedemptionToCrawlReceipts < ActiveRecord::Migration[6.0]
  def change
    add_reference :crawl_receipts, :redemption, null: true, foreign_key: true
  end
end
