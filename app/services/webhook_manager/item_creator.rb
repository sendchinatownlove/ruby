# frozen_string_literal: true

# Validates idempotency using the ExistingEvent Model
module WebhookManager
  class ItemCreator < BaseService
    attr_reader :item_type, :seller_id, :payment_intent

    def initialize(params)
      @item_type = params[:item_type]
      @seller_id = params[:seller_id]
      @payment_intent = params[:payment_intent]
    end

    def call
      seller = Seller.find_by(seller_id: seller_id)
      Item.create!(
        seller: seller,
        purchaser: payment_intent.purchaser,
        item_type: item_type,
        payment_intent: payment_intent,
        campaign_id: payment_intent.campaign_id
      )
    end
  end
end
