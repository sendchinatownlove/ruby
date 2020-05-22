# frozen_string_literal: true

# Validates idempotency using the ExistingEvent Model
class ItemAndDonationCreator < BaseService
  attr_reader :seller_id, :purchaser, :payment_intent, :amount

  def initialize(params)
    @seller_id = params[:seller_id]
    @purchaser = params[:purchaser]
    @payment_intent = params[:payment_intent]
    @amount = params[:amount]
  end

  def call
    # existing_event = ExistingEvent.new(
    #   idempotency_key: idempotency_key,
    #   event_type: event_type
    # )

    # unless existing_event.save
    #   Rails.logger.info "Not idempotent idempotency_key: #{idempotency_key};"\
    #                     " event_type: #{event_type}"
    #   raise ExceptionHandler::DuplicateRequestError,
    #         'Request was already received'
    # end
    new_item = create_item(
      item_type: :donation,
      seller_id: seller_id,
      purchaser: purchaser,
      payment_intent: payment_intent
    )
    create_donation(item: new_item, amount: amount)
  end
end
