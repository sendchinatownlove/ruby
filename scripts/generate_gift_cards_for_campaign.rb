def max_campaign(payment_intent_id, campaign_id)
  Item.transaction do
    campaign = Campaign.find(campaign_id)
    payment_intent = PaymentIntent.find(payment_intent_id)
    payment_intent.update!(recipient: campaign.distributor.contact)

    (1..(campaign.target_amount / campaign.price_per_meal)).each do |_|
      WebhookManager::GiftCardCreator.call(
        {
          amount: campaign.price_per_meal,
          single_use: true,
          campaign_id: campaign.id,
          distributor_id: campaign.distributor_id,
          seller_id: campaign.seller.seller_id,
          payment_intent: payment_intent,
        }
      )
    end
  end
end
