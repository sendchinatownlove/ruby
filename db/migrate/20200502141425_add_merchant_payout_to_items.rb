class AddMerchantPayoutToItems < ActiveRecord::Migration[6.0]
  def change
    add_reference :items, :merchant_payout, foreign_key: true
  end
end
