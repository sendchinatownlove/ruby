class AddTimestampsToCrawlReceipts < ActiveRecord::Migration[6.0]
  def change
    change_table(:crawl_receipts) { |t| t.timestamps}
  end
end
