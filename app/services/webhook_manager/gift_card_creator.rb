# frozen_string_literal: true

# Creates donation and item with the corresponding payload
module WebhookManager
  class GiftCardCreator < BaseService
    attr_reader :seller_id, :payment_intent, :amount, :single_use

    def initialize(params)
      @seller_id = params[:seller_id]
      @payment_intent = params[:payment_intent]
      @amount = params[:amount]
      @single_use = params[:single_use]
    end

    def call
      ActiveRecord::Base.transaction do
        seller = Seller.find_by(seller_id: seller_id)
        item = WebhookManager::ItemCreator.call({
                                                  item_type: :gift_card,
                                                  seller_id: seller_id,
                                                  payment_intent: payment_intent
                                                })

        gift_card_detail = GiftCardDetail.create!(
          expiration: Date.today + 1.year,
          item: item,
          gift_card_id: GiftCardIdGenerator.generate_gift_card_id,
          seller_gift_card_id: GiftCardIdGenerator.generate_seller_gift_card_id(seller_id: seller_id),
          recipient: payment_intent.recipient,
          single_use: single_use
        )
        amount_after_fees = WebhookManager::FeeManager.call({
          payment_intent: payment_intent
          amount: amount
        })
        GiftCardAmount.create!(value: amount_after_fees, gift_card_detail: gift_card_detail)
        payment_intent.successful = true
        payment_intent.save!

        gift_card_detail
      end
    end
  end
end
