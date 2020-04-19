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
    if !is_valid_callback(callback_body, callback_signature)
      # Fail if the signature is invalid
      raise InvalidSquareSignature.new 'Invalid Signature Header from Square'
    end

    # Load the JSON body into a hash
    callback_body_json = JSON.parse(callback_body)

    # If the notification indicates a PAYMENT_UPDATED event...
    if callback_body_json['type'] == 'payment.updated'
      # Get the ID of the updated payment
      payment_id = callback_body_json['entity_id']

      # Get the ID of the payment's associated location
      location_id = callback_body_json['object']['payment']['location_id']
      payment_id = callback_body_json['data']['id']

      # Send a request to the Retrieve Payment endpoint to get the updated payment's full details
      response = Unirest.get CONNECT_HOST + '/v1/' + location_id + '/payments/' + payment_id,
                    headers: REQUEST_HEADERS
      # Perform an action based on the returned payment (in this case, simply log it)
      puts JSON.pretty_generate(response.body)

      # Fulfill the purchase
      handle_payment_intent_succeeded(
        square_payment_id: payment_id,
        square_location_id: location_id
      )
    end
  end

  # Validates HMAC-SHA1 signatures included in webhook notifications to ensure notifications came from Square
  def is_valid_square_callback(callback_body, callback_signature)

    # Combine your webhook notification URL and the JSON body of the incoming request into a single string
    string_to_sign = 'https://api.sendchinatownlove.com/webhooks' + callback_body

    # Generate the HMAC-SHA1 signature of the string, signed with your webhook signature key
    string_signature = Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', WEBHOOK_SIGNATURE_KEY, string_to_sign))

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

    # Mark the payment as successful first so that we know that we received the money
    payment_intent.successful = true
    payment_intent.save

    items = JSON.parse(payment_intent.line_items)
    items.each do |item|
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
          payment_intent_id: payment_intent_id,
          seller_id: seller_id
        )
      else
        raise InvalidLineItem.new 'Unsupported ItemType. Please verify the line_item.name.'
      end
    end
  end

  def create_donation(item:, amount:)
    DonationDetail.create!(
      item: item,
      amount: amount
    )
  end

  def create_gift_card(item:, amount:, payment_intent_id:, seller_id:)
    gift_card_id = generate_gift_card_id(payment_intent_id: payment_intent_id)
    seller_gift_card_id = generate_seller_gift_card_id(
      payment_intent_id: payment_intent_id,
      seller_id: seller_id
    )

    gift_card_detail = GiftCardDetail.create!(
      expiration: Date.today + 100.days,
      item: item,
      gift_card_id: gift_card_id,
      seller_gift_card_id: seller_gift_card_id
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

  def generate_gift_card_id(payment_intent_id:)
    for i in 1..50 do
      seed = "#{Time.current}#{ENV['HASH_KEY_CONSTANT']}#{payment_intent_id}#{i}"

      potential_id = Digest::MD5.hexdigest(seed)
      # Use this ID if it's not already taken
      return potential_id if !GiftCardDetail.where(gift_card_id: potential_id).present?
    end
    raise CannotGenerateUniqueHash.new 'Error generating unique gift_card_id'
  end

  def generate_seller_gift_card_id(payment_intent_id:, seller_id:)
    for i in 1..50 do
      seed = "#{Time.current}#{ENV['HASH_KEY_CONSTANT']}#{payment_intent_id}#{i}#{seller_id}"

      hash = Digest::MD5.hexdigest(seed).upcase
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
