# frozen_string_literal: true

# Creates donation and item with the corresponding payload
module WebhookManager
  class GiftCardCreator < BaseService
    attr_reader :seller_id, :payment_intent, :amount, :single_use, :project_id, :campaign_id, :distributor_id

    def initialize(params)
      @seller_id = params[:seller_id]
      @payment_intent = params[:payment_intent]
      @amount = params[:amount]
      @single_use = params[:single_use]
      @project_id = params[:project_id]
      @campaign_id = params[:campaign_id]
      @distributor_id = params[:distributor_id]
    end

    def call
      if payment_intent.present? && payment_intent.recipient.blank?
        raise InvalidParameterError, 'Payment intent must have a recipient in order to create gift cards'
      end

      ActiveRecord::Base.transaction do
        distributor = Distributor.find_by(id: distributor_id)
        distributor_contact = nil
        if distributor
          distributor_contact = Contact.find_by(id: distributor.contact_id)
        end

        item = WebhookManager::ItemCreator.call(
          {
            item_type: :gift_card,
            seller_id: seller_id,
            payment_intent: payment_intent,
            project_id: project_id,
            campaign_id: campaign_id,
          })

        gift_card_detail = GiftCardDetail.create!(
          expiration: Date.today + 1.year,
          item: item,
          gift_card_id: GiftCardIdGenerator.generate_gift_card_id,
          seller_gift_card_id: GiftCardIdGenerator.generate_seller_gift_card_id(seller_id: seller_id),
          recipient: payment_intent ? payment_intent.recipient : distributor_contact,
          single_use: single_use
        )
        GiftCardAmount.create!(value: amount, gift_card_detail: gift_card_detail)

        gift_card_detail
      end
    end
  end
end
