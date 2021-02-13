# frozen_string_literal: true

namespace :campaign_goals do
  task :create_gift_cards_to_max_campaign, %i[payment_intent_id campaign_id] => [:environment] do |_task, args|
    desc 'Max out campaign goals with gift cards'
    Item.transaction do
      campaign = Campaign.find(args.campaign_id)
      payment_intent = PaymentIntent.find(args.payment_intent_id)
      payment_intent.update!(campaign: campaign)
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
end
