# frozen_string_literal: true

class AddTimestampsToCrawlReceipts < ActiveRecord::Migration[6.0]
  def change
    change_table(:crawl_receipts, &:timestamps)
  end
end
