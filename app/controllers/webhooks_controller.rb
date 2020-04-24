class WebhooksController < ApplicationController
  # POST /webhooks
  def create
    if request.env['HTTP_STRIPE_SIGNATURE'].present?
      handle_stripe_event
    elsif request.env['HTTP_X_SQUARE_SIGNATURE'].present?
      handle_square_event
    end

    json_response({})
  end

  def handle_stripe_event
    Stripe.api_key = ENV['STRIPE_API_KEY']

    # Verify webhook signature and extract the event
    # See https://stripe.com/docs/webhooks/signatures for more information.
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_KEY']
    payload = request.body.read

    event = Stripe::Webhook.construct_event(
      payload, sig_header, endpoint_secret
    )

    # Handle the payment_intent.succeeded event
    if event['type'] == 'payment_intent.succeeded'
      payment_intent = event['data']['object']

      # Fulfill the purchase
      handle_payment_intent_succeeded(stripe_payment_id: payment_intent['id'])
    end
  end

  def handle_square_event
    # Get the JSON body and HMAC-SHA1 signature of the incoming POST request
    callback_signature = request.env['HTTP_X_SQUARE_SIGNATURE']
    callback_body = request.body.string

    # Validate the signature
    if !is_valid_square_callback(callback_body, callback_signature)
      # Fail if the signature is invalid
      raise InvalidSquareSignature.new 'Invalid Signature Header from Square'
    end

    # Load the JSON body into a hash
    callback_body_json = JSON.parse(callback_body)

    # If the notification indicates a PAYMENT_UPDATED event...
    if callback_body_json['type'] == 'payment.updated'
      payment = callback_body_json['data']['object']['payment']
      if payment['status'] == 'COMPLETED'
        # Get the ID of the updated payment
        payment_id = callback_body_json['entity_id']

        # Get the ID of the payment's associated location
        location_id = payment['location_id']
        payment_id = callback_body_json['data']['id']

        # Fulfill the purchase
        handle_payment_intent_succeeded(
          square_payment_id: payment_id,
          square_location_id: location_id
        )
      end
    end
  end

  # Validates HMAC-SHA1 signatures included in webhook notifications to ensure notifications came from Square
  def is_valid_square_callback(callback_body, callback_signature)

    # Combine your webhook notification URL and the JSON body of the incoming request into a single string
    string_to_sign = 'https://api.sendchinatownlove.com/webhooks' + callback_body

    # Generate the HMAC-SHA1 signature of the string, signed with your webhook signature key
    string_signature = Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', ENV['SQUARE_WEBHOOK_SIGNATURE_KEY'], string_to_sign))

    # Hash the signatures a second time (to protect against timing attacks)
    # and compare them
    return Digest::SHA1.base64digest(string_signature) == Digest::SHA1.base64digest(callback_signature)
  end

  def handle_payment_intent_succeeded(
    square_payment_id: nil,
    square_location_id: nil,
    stripe_payment_id: nil
  )
    if square_payment_id.present?
      payment_intent_id = square_payment_id
      payment_intent = PaymentIntent.find_by(
        square_payment_id: square_payment_id,
        square_location_id: square_location_id
      )
    else
      payment_intent_id = stripe_payment_id
      payment_intent = PaymentIntent.find_by(stripe_id: payment_intent_id)
    end

    # TODO(jtmckibb): Fix emails
    # CustomerMailer.with(payment_intent: payment_intent).send_receipt.deliver_now

    # TODO(jtmckibb): Mark in the payment intent that the card has been successfully processed by Square
    #                 The other "success" means that the completed payment has been processed by us
    #                 I'm thinking that we're going to need to convert this "success" boolean into a FSM
    #                 SquareTransactionSucceeded -> EmailsSent -> ItemsCreated
    #                 Or since one doesn't depend on another we can make it an array of events. We could
    #                 even start multiple threads

    # TODO(jtmckibb): Instead of just checking for successful, we'd need to check that there are no other
    #                 unfinished actions to complete in the checklist. So far our checklist is:
    #                  - processItems (if any one Item fails, be sure not to create any)
    #                  - sendEmail
    #                 The new check would be like, if all of the required actions are complete, then raise
    #                 the DuplicatePaymentCompletedError, else finish the unfinished actions.
    # If the payment has already been processed
    if payment_intent.successful
      raise DuplicatePaymentCompletedError.new "This payment has already been received as COMPLETE payment_intent.id: #{payment_intent.id}"
    end

    items = JSON.parse(payment_intent.line_items)
    items.each do |item|
      # TODO(jtmckibb): Add some tracking that tracks if it breaks somewhere here

      amount = item['amount']
      seller_id = item['seller_id']
      case item['item_type']
      when 'donation'
        item = create_item(
          item_type: :donation,
          seller_id: seller_id,
          email: payment_intent.email,
          payment_intent: payment_intent
        )
        create_donation(item: item, amount: amount)
      when 'gift_card'
        item = create_item(
          item_type: :gift_card,
          seller_id: seller_id,
          email: payment_intent.email,
          payment_intent: payment_intent
        )

        create_gift_card(
          item: item,
          amount: amount,
          seller_id: seller_id
        )
      else
        raise InvalidLineItem.new 'Unsupported ItemType. Please verify the line_item.name.'
      end
    end

    # Mark the payment as successful once we've recorded each object purchased in our DB
    # eg) Donation, Gift Card, etc.
    payment_intent.successful = true
    payment_intent.save
  end

  def create_donation(item:, amount:)
    DonationDetail.create!(
      item: item,
      amount: amount
    )
  end

  def create_gift_card(item:, amount:, seller_id:)
    gift_card_detail = GiftCardDetail.create!(
      expiration: Date.today + 1.year,
      item: item,
      gift_card_id: generate_gift_card_id,
      seller_gift_card_id: generate_seller_gift_card_id(seller_id: seller_id)
    )
    GiftCardAmount.create!(value: amount, gift_card_detail: gift_card_detail)
  end

  def create_item(item_type:, seller_id:, email:, payment_intent:)
    seller = Seller.find_by(seller_id: seller_id)
    Item.create!(
      seller: seller,
      email: email,
      item_type: item_type,
      payment_intent: payment_intent
    )
  end

  def generate_gift_card_id()
    for i in 1..50 do
      potential_id = SecureRandom.uuid
      # Use this ID if it's not already taken
      return potential_id if !GiftCardDetail.where(gift_card_id: potential_id).present?
    end
    raise CannotGenerateUniqueHash.new 'Error generating unique gift_card_id'
  end

  def generate_seller_gift_card_id(seller_id:)
    for i in 1..50 do
      hash = SecureRandom.hex.upcase
      potential_id_prefix = hash[0...3]
      potential_id_suffix = hash[3...5]
      potential_id = "##{potential_id_prefix}-#{potential_id_suffix}"
      # Use this ID if it's not already taken
      return potential_id if !GiftCardDetail.where(seller_gift_card_id: potential_id)
                                            .joins(:item)
                                            .where(
                                              items: { seller_id: seller_id }
                                            ).present?
    end
    raise CannotGenerateUniqueHash.new 'Error generating unique gift_card_id'
  end
end
