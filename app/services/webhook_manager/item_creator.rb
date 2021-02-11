# frozen_string_literal: true

# Validates idempotency using the ExistingEvent Model
module WebhookManager
  class ItemCreator < BaseService
    attr_reader :item_type, :seller_id, :project_id, :payment_intent, :campaign_id

    def initialize(params)
      @item_type = params[:item_type]
      @seller_id = params[:seller_id]
      @project_id = params[:project_id]
      @payment_intent = params[:payment_intent]
      @campaign_id = params[:campaign_id]
    end

    def call
      seller = Seller.find_by(seller_id: seller_id)
      project = Project.find_by(id: project_id)
      if seller.present? && project.present?  # Mega GAM item creation will have seller and project.
        Item.create!(
          seller: seller,
          project: project,
          item_type: item_type,
          payment_intent: payment_intent,
          campaign_id: campaign_id,
        )
      elsif seller.present?
        Item.create!(
          seller: seller,
          purchaser: payment_intent.purchaser,
          item_type: item_type,
          payment_intent: payment_intent,
          campaign_id: payment_intent.campaign_id
        )
      else
        Item.create!(
          project: project,
          purchaser: payment_intent.purchaser,
          item_type: item_type,
          payment_intent: payment_intent,
          campaign_id: campaign_id,
        )
      end
    end
  end
end
