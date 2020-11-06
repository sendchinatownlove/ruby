# frozen_string_literal: true

require 'rest-client'

# TODO(jmckibben): This class needs a lot of refactoring
class WebhooksController < ApplicationController
  # POST /webhooks
  def create
    handle_square_event

    json_response({})
  end

  private

  def handle_square_event
    # Get the JSON body and HMAC-SHA1 signature of the incoming POST request
    callback_signature = request.env['HTTP_X_SQUARE_SIGNATURE']
    callback_body = request.body.string

    # Validate the signature
    SquareManager::WebhookValidator.call({
                                           url: ENV['RAILS_WEBHOOK_URL'],
                                           callback_body: callback_body,
                                           callback_signature:
                                               callback_signature
                                         })

    # Load the JSON body into a hash
    callback_body_json = JSON.parse(callback_body)
    square_event_type = sanitize_square_type(callback_body_json['type'])

    DuplicateRequestValidator.call({
                                     idempotency_key:
                                         callback_body_json['event_id'],
                                     event_type: square_event_type
                                   })

    # If the notification indicates a PAYMENT_UPDATED event...
    case square_event_type
    when 'payment_updated'
      payment = callback_body_json['data']['object']['payment']
      if payment['status'] == 'COMPLETED'
        # Fulfill the purchase
        handle_payment_intent_succeeded(
          square_payment_id: payment['id'],
          square_location_id: payment['location_id']
        )
      end
    when 'refund_created'
      refund = callback_body_json['data']['object']['refund']

      payment_intent = PaymentIntent.find_by(
        square_payment_id: refund['payment_id']
      )

      Refund.create!(
        square_refund_id: refund['id'],
        status: refund['status'],
        payment_intent: payment_intent
      )
    when 'refund_updated'
      square_refund = callback_body_json['data']['object']['refund']
      status = square_refund['status']

      refund = Refund.find_by(square_refund_id: square_refund['id'])
      refund.update(status: status)

      case status
      when 'COMPLETED'
        # Wrapped in a transaction so that if any one of them fail, none of the
        # Items are updated
        ActiveRecord::Base.transaction do
          refund.payment_intent.items.each do |item|
            item.update!(refunded: true)
          end
        end
      end
    end
  end

  def sanitize_square_type(square_event_type)
    square_event_type.gsub('.', '_')
  end

  def handle_payment_intent_succeeded(
    square_payment_id: nil,
    square_location_id: nil
  )
    payment_intent = PaymentIntent.find_by(
      square_payment_id: square_payment_id,
      square_location_id: square_location_id
    )

    # TODO(jtmckibb): Each payment has an associated FSM. If we see the start
    #                 of a payment, we should expect for it to be completed.
    #                 If it isn't, then we should record it. Similarly with
    #                 refunds.

    # TODO(jtmckibb): If Square notifies us of a payment completion, or refund
    #                 and for some reason we fail in the middle of reacting to
    #                 that event, we want to be able to save the place that we
    #                 failed at and whenever Square tries to notify us again,
    #                 finish where we left off.

    # If the payment has already been processed
    if payment_intent.successful
      # rubocop:disable Layout/LineLength
      raise(
        DuplicatePaymentCompletedError,
        "This payment has already been received as COMPLETE payment_intent.id: #{payment_intent.id}"
      )
      # rubocop:enable Layout/LineLength
    end

    items = JSON.parse(payment_intent.line_items)
    recipient = payment_intent.recipient
    is_donation = false

    items.each do |item_json|
      # TODO(jtmckibb): Add some tracking that tracks if it breaks somewhere
      # here

      amount = item_json['amount']
      seller_id = item_json['seller_id']
      if seller_id.eql?(Seller::POOL_DONATION_SELLER_ID)
        PoolDonationValidator.call({ type: item_json['item_type'] })

        WebhookManager::PoolDonationCreator.call(
          {
            seller_id: seller_id,
            payment_intent: payment_intent,
            amount: amount
          }
        )

        EmailManager::PoolDonationReceiptSender.call(
          {
            payment_intent: payment_intent,
            amount: amount,
            email: payment_intent.purchaser.email
          }
        )
      else
        merchant_name = Seller.find_by(seller_id: seller_id).name
        case item_json['item_type']
        when 'donation'
          is_donation ||= true

          WebhookManager::DonationCreator.call(
            {
              seller_id: seller_id,
              payment_intent: payment_intent,
              amount: amount
            }
          )
        when 'gift_card'
          gift_a_meal = payment_intent.campaign.present?

          # TODO(justintmckibben): Relate the gift cards to the campaign
          gift_card_detail = WebhookManager::GiftCardCreator.call(
            {
              amount: amount,
              seller_id: seller_id,
              payment_intent: payment_intent,
              single_use: gift_a_meal
            }
          )
          # Gift a meal purchases are technically donations to the purchaser
          if gift_a_meal
            is_donation ||= true
          else
            EmailManager::GiftCardReceiptSender.call(
              {
                payment_intent: payment_intent,
                amount: amount,
                merchant: merchant_name,
                gift_card_detail: gift_card_detail,
                email: payment_intent.recipient.email
              }
            )
          end
        else
          raise(
            InvalidLineItem,
            'Unsupported ItemType. Please verify the line_item.name.'
          )
        end
      end
    end

    if is_donation
      # Send separate email for each seller.
      grouped_items = items.group_by { |li| li['seller_id'] }
      grouped_items.each_key do |sid|
        EmailManager::DonationReceiptSender.call(
          {
            payment_intent: payment_intent,
            amount: grouped_items[sid].map { |li| li['amount'].to_f }.sum,
            merchant: Seller.find_by(seller_id: sid).name,
            email: payment_intent.purchaser.email
          }
        )
      end
    end
  end
end
