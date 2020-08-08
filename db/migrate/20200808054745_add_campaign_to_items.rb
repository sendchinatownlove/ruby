class AddCampaignToItems < ActiveRecord::Migration[6.0]
  def change
    Seller.all.each do |seller|
      # Currently there is max one campaign per Seller
      campaign = Campaign.find_by(seller_id: seller.id)
      # We want to modify all Items including the refunded ones to be associated
      # to the correct campaign
      item = Item.joins(:gift_card_detail).where(items: { seller_id: seller.id, single_use: true })
      item.update(campaign: campaign)
      item.payment_intent.update(campaign: campaign)
      # NB(justintmckibben): After we run this migration, single_use isn't the
      #                      the indicator for GAM meals anymore. Now items
      #                      being associated to a campaign is the new
      #                      indicator
    end
  end
end
