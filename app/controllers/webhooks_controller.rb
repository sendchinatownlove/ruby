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
        item = create_item(
          item_type: :donation,
          seller_id: seller_id,
          customer_id: customer_id
        )
        create_donation(item: item, amount: amount)
      when 'Gift Card'
        item = create_item(
          item_type: :gift_card,
          seller_id: seller_id,
          customer_id: customer_id
        )
        create_gift_card(item: item, amount: amount)
      else
        raise InvalidLineItem.new 'Unsupported ItemType. Please verify the line_item.name.'
      end
    end
  end

  def create_donation(item:, amount:)
    # TODO(jtmckibb): Create Charge here
    DonationDetail.create!(
      item: item,
      amount: amount
    )
  end

  def create_gift_card(item:, amount:)
    # TODO(jtmckibb): Create Charge here
    gift_card_detail = GiftCardDetail.create!(
      expiration: Time.current + 100.days,
      item: item,
      gift_card_id: 'BOIWJEf'
    )
    GiftCardAmount.create!(value: amount, gift_card_detail: gift_card_detail)
  end

  def create_item(item_type:, seller_id:, customer_id:)
    seller = Seller.find_by(seller_id: seller_id)
    Item.create!(
      seller: seller,
      stripe_customer_id: customer_id,
      item_type: item_type
    )
  end
end
