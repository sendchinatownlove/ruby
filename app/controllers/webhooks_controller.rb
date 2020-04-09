class WebhooksController < ApplicationController
  # POST /webhooks
  def create
    payload = request.body.read
    event = nil

    # Verify webhook signature and extract the event
    # See https://stripe.com/docs/webhooks/signatures for more information.
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = 'whsec_8I8JI2kT6B3RdUR39usVosRMhRvLVrcH'
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      status 400
      return
    end

    # Handle the checkout.session.completed event
    if event['type'] == 'checkout.session.completed'
      session = event['data']['object']

      # Fulfill the purchase
      handle_checkout_session(session: session)
    end

    json_response({})
  end

  def handle_checkout_session(session:)
    items = session['display_items']
    seller_id = session['metadata']['merchant_id']
    customer_id = session['customer']['id']
    items.each do |item|
      amount = item['amount']
      case item['custom']['name']
      when 'Donation'
        create_donation(amount: amount, customer_id: customer_id, seller_id: seller_id)
      when 'Gift Card'
        # TODO(jtmckibb): Create Gift Card object
        # create_gift_card(amount: amount, customer_id: customer_id, seller_id: seller_id)
      else
        # TODO(jtmckibb): Replace with right json error
        raise JSON::ParserError.new 'Unsupported ItemType'
      end
    end
  end

  def create_donation(amount:, customer_id:, seller_id:)
    # TODO(jtmckibb): Create Charge here
    puts amount, customer_id, seller_id
    seller = Seller.find_by(seller_id: seller_id)
    item = Item.create!(
      seller: seller,
      stripe_customer_id: customer_id,
      item_type: 'DONATION'
    )

    DonationDetail.create!(
      item: item,
      amount: amount
    )
  end

  def create_gift_card(amount:, customer_id:, seller_id:)
    # TODO(jtmckibb): Create Charge here

    gift_card_amount = GiftCardAmount.create!(amount: amount)
    gift_card_detail = GiftCardDetail.create!(
      gift_card_amount: gift_card_amount
    )
    Item.create!(
      seller_id: seller_id,
      stripe_customer_id: customer_id,
      item_type: 'GIFT-CARD',
      gift_card_detail: gift_card_detail
    )
  end
end
