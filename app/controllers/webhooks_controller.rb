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
    donation_event = nil

    items.each do |item_json|
      # TODO(jtmckibb): Add some tracking that tracks if it breaks somewhere
      # here

      amount = item_json['amount']
      seller_id = item_json['seller_id']
      if seller_id.eql?(Seller::POOL_DONATION_SELLER_ID)
        PoolDonationValidator.call({ type: item_json['item_type'] })

        # TODO(jtmckibb): This is a very inefficient sort, since each time we
        #                 call amount_raised, it has to fetch all of the
        #                 associated Items, DonationDetails, and GiftCardDetails
        #                 Then for each GiftCardDetail, it has to fetch every
        #                 amount in an N+1 query, then sum everything. This is
        #                 all in an N log N sort—which is horrible. Ideally,
        #                 we would memoize amount_raised, and fix the N+1 query
        #                 in GiftCardDetail that calculates amount.
        @donation_sellers = Seller.filter_by_accepts_donations.sort_by do |s|
          s.amount_raised
        end

        # calculate amount per merchant
        # This will break if we ever have zero merchants but are still
        # accepting pool donations.
        amount_per = (amount.to_f / @donation_sellers.count.to_f).floor
        remainder = amount % @donation_sellers.count

        @donation_sellers.each do |seller|
          next if seller.seller_id.eql?(Seller::POOL_DONATION_SELLER_ID)

          create_item_and_donation(
            seller_id: seller.seller_id,
            payment_intent: payment_intent,
            amount: amount_per + (remainder > 0 ? 1 : 0)
          )
          remainder -= 1
        end
        EmailManager::PoolDonationReceiptSender.call({
            payment_intent: payment_intent,
            amount: amount,
        })
      else
        merchant_name = Seller.find_by(seller_id: seller_id).name
        case item_json['item_type']
        when 'donation'
          create_item_and_donation(
            seller_id: seller_id,
            payment_intent: payment_intent,
            amount: amount
          )
          donation_event ||= true
        when 'gift_card'
          item = create_item(
            item_type: :gift_card,
            seller_id: seller_id,
            payment_intent: payment_intent
          )

          gift_card_detail = create_gift_card(
            item: item,
            amount: amount,
            seller_id: seller_id,
            recipient: recipient,
            single_use: item_json['is_distribution']
          )
          EmailManager::GiftCardReceiptSender.call({
              payment_intent: payment_intent,
              amount: amount,
              merchant: merchant_name,
              gift_card_detail: gift_card_detail
          })
        else
          raise(
            InvalidLineItem,
            'Unsupported ItemType. Please verify the line_item.name.'
          )
        end
      end
    end

    if donation_event
      # Send separate email for each seller.
      grouped_items = items.group_by { |li| li["seller_id"] }
      grouped_items.keys.each do |sid|
        EmailManager::DonationReceiptSender.call({
            payment_intent: payment_intent,
            amount: grouped_items[sid].map { |li| li["amount"].to_f }.sum,
            merchant: Seller.find_by(seller_id: sid).name
        })
      end
    end

    # Mark the payment as successful once we've recorded each object purchased
    # in our DB eg) Donation, Gift Card, etc.
    payment_intent.successful = true
    payment_intent.save
  end

  def create_item_and_donation(seller_id:, payment_intent:, amount:)
    new_item = create_item(
      item_type: :donation,
      seller_id: seller_id,
      payment_intent: payment_intent
    )
    create_donation(item: new_item, amount: amount)
  end

  def create_donation(item:, amount:)
    DonationDetail.create!(
      item: item,
      amount: amount
    )
  end

  def create_gift_card(item:, amount:, seller_id:, recipient:, single_use:)
    gift_card_detail = GiftCardDetail.create!(
      expiration: Date.today + 1.year,
      item: item,
      gift_card_id: generate_gift_card_id,
      seller_gift_card_id: generate_seller_gift_card_id(seller_id: seller_id),
      recipient: recipient,
      single_use: single_use
    )
    GiftCardAmount.create!(value: amount, gift_card_detail: gift_card_detail)
    gift_card_detail
  end

  def create_item(item_type:, seller_id:, payment_intent:)
    WebhookManager::ItemCreator.call({
      item_type: item_type,
      seller_id: seller_id,
      payment_intent: payment_intent
    })
  end

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
