# frozen_string_literal: true

# Creates donation and item with the corresponding payload
module WebhookManager
  class DonationCreator < BaseService
    attr_reader :seller_id, :payment_intent, :amount

    def initialize(params)
      @seller_id = params[:seller_id]
      @payment_intent = params[:payment_intent]
      @amount = params[:amount]
    end

    def call
      ActiveRecord::Base.transaction do
        seller = Seller.find_by(seller_id: seller_id)
        item = WebhookManager::ItemCreator.call({
                                                  item_type: :donation,
                                                  seller_id: seller_id,
                                                  payment_intent: payment_intent
                                                })
        donation = DonationDetail.create!(
          item: item,
          amount: amount
        )
        payment_intent.successful = true
        payment_intent.save!

        donation
      end
    end
  end
end
