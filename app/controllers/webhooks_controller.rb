class WebhooksController < ApplicationController
  # POST /webhooks
  def create
    payload = request.body.read
    event = nil

    # Verify webhook signature and extract the event
    # See https://stripe.com/docs/webhooks/signatures for more information.
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = 'whsec_8I8JI2kT6B3RdUR39usVosRMhRvLVrcH'

    event = Stripe::Webhook.construct_event(
      payload, sig_header, endpoint_secret
    )

    # Handle the payment_intent.succeeded event
    if event['type'] == 'payment_intent.succeeded'
      payment_intent = event['data']['object']

      # Fulfill the purchase
      handle_payment_intent_succeeded(payment_intent_id: payment_intent['id'])
    end

    json_response({})
  end

  def handle_payment_intent_succeeded(payment_intent_id:)
    payment_intent = PaymentIntent.find_by(stripe_id: payment_intent_id)
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
    # TODO(jmckibb): Make this a secret
    secret_hash_key = "some_secret_key123"

    for i in 1..50 do
      seed = "#{Date.today}#{secret_hash_key}#{payment_intent_id}#{i}"

      potential_id = Digest::MD5.hexdigest(seed)
      # Use this ID if it's not already taken
      return potential_id if !GiftCardDetail.where(gift_card_id: potential_id).present?
    end
    raise CannotGenerateUniqueHash.new 'Error generating unique gift_card_id'
  end

  def generate_seller_gift_card_id(payment_intent_id:, seller_id:)
    # TODO(jmckibb): Make this a secret
    secret_hash_key = "some_secret_key123"

    for i in 1..50 do
      seed = "#{Time.current}#{secret_hash_key}#{payment_intent_id}#{i}#{seller_id}"

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
