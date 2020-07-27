class AddCampaignToPaymentIntent < ActiveRecord::Migration[6.0]
  def change
    add_reference :payment_intents, :campaign, null: true, foreign_key: true
  end
end
