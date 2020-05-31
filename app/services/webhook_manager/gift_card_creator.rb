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
          gift_card_id: generate_gift_card_id,
          seller_gift_card_id: generate_seller_gift_card_id(seller_id: seller_id),
          recipient: payment_intent.recipient,
          single_use: single_use
        )
        GiftCardAmount.create!(value: amount, gift_card_detail: gift_card_detail)
        payment_intent.successful = true
        payment_intent.save!

        gift_card_detail
      end
    end

    private

    def generate_gift_card_id
      (1..50).each do |_i|
        potential_id = SecureRandom.uuid
        # Use this ID if it's not already taken
        unless GiftCardDetail.where(gift_card_id: potential_id).present?
          return potential_id
        end
      end
      raise CannotGenerateUniqueHash, 'Error generating unique gift_card_id'
    end

    def generate_seller_gift_card_id(seller_id:)
      (1..50).each do |_i|
        hash = generate_seller_gift_card_id_hash.upcase
        potential_id_prefix = hash[0...3]
        potential_id_suffix = hash[3...5]
        potential_id = "##{potential_id_prefix}-#{potential_id_suffix}"
        # Use this ID if it's not already taken
        return potential_id unless GiftCardDetail.where(
          seller_gift_card_id: potential_id
        ).joins(:item).where(items: { seller_id: seller_id }).present?
      end
      raise CannotGenerateUniqueHash, 'Error generating unique gift_card_id'
    end

    def generate_seller_gift_card_id_hash
      ('a'..'z').to_a.sample(5).join
    end
  end
end
