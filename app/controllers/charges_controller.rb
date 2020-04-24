require 'securerandom'

class ChargesController < ApplicationController

  # POST /charges
  def create
    line_items = charge_params[:line_items].map(&:to_h)

    # Validate each Item and get all ItemTypes
    item_types = Set.new
    seller_names = Set.new
    line_items.each do |item|
      validate(line_item: item)
      item_types.add item['item_type']
      seller = Seller.find_by(seller_id: item['seller_id'])
      seller_names.add seller.name
    end

    # Total all Items
    amount = line_items.inject(0) { |sum, item| sum + item['amount'] * item['quantity'] }

    description = generate_description(
      seller_names: seller_names.to_a,
      item_types: item_types
    )

    email = charge_params[:email]
    if charge_params[:is_square]
      payment = create_square_payment_request(
        source_id: charge_params[:nonce],
        amount: amount,
        note: description,
        email: email,
        line_items: line_items)
    else
      payment = create_stripe_payment_request(
        amount: amount,
        email: email,
        description: description,
        line_items: line_items)
    end

    json_response(payment)
  end

  private

  def charge_params
    params.require(:line_items)
    params.require(:email)
    params.require(:is_square)
    params.require(:nonce) if params[:is_square]
    params.permit(:email, :nonce, :is_square, line_items: [[:amount, :currency, :item_type, :quantity, :seller_id]])
  end

  def validate(line_item:)
    [:amount, :currency, :item_type, :quantity, :seller_id].each do |attribute|
      unless line_item.key?(attribute)
        raise ActionController::ParameterMissing.new "param is missing or the value is empty: #{attribute}"
      end
    end

    unless ['gift_card', 'donation'].include? line_item['item_type']
      raise InvalidLineItem.new 'line_item must be named `gift_card` or `donation`'
    end

    seller_id = line_item['seller_id']
    unless Seller.find_by(seller_id: seller_id).present?
      raise InvalidLineItem.new "Seller does not exist: #{seller_id}"
    end

    unless line_item['amount'].is_a? Integer
      raise InvalidLineItem.new 'line_item.amount must be an Integer'
    end

    unless line_item['quantity'].is_a? Integer
      raise InvalidLineItem.new 'line_item.quantity must be an Integer'
    end

    amount = line_item['amount']
    raise InvalidLineItem.new 'Amount must be at least $0.50 usd' unless amount >= 50
  end

  def generate_description(seller_names:, item_types:)
    description = 'Thank you for supporting '
    description += EmailHelper.format_sellers_as_list(
        seller_names: seller_names
    )
    description += '.'
    if item_types.include? 'gift_card'
      description += ' Your gift card(s) will be emailed to you when the seller opens back up.'
    end

    description
  end

  def create_square_payment_request(source_id:, amount:, note:, email:, line_items:)
    api_client = Square::Client.new(
      access_token: ENV['SQUARE_ACCESS_TOKEN'],
      environment: if Rails.env.production? then 'production' else 'sandbox' end
    )

    # Default location in prod:
    # https://squareup.com/dashboard/locations/3D0QAW4CSZJWZ
    # In the future we might associate a Square location with each seller that we onboard
    # This will give us access into reporting for each merchant.
    # The reason why I'm not doing this work right now is because you can only associate
    # one location per charge, but we might want to allow for people to add multiple gift
    # cards into their card for diffrent Sellers, and then check out all at once.
    square_location_id = ENV['SQUARE_LOCATION_ID']

    request_body = {
      source_id: source_id,
      idempotency_key: SecureRandom.uuid,
      amount_money: {
        amount: amount,
        currency: 'USD',
      },
      buyer_email_address: email,
      note: note,
      location_id: square_location_id
    }

    api_response = api_client.payments.create_payment(body: request_body)

    errors = api_response.errors
    raise SquarePaymentsError.new(
      errors: errors,
      status_code: api_response.status_code
    ) if errors.present?

    payment = api_response.data.payment
    receipt_url = payment.receipt_url

    # Creates a pending PaymentIntent. See webhooks_controller to see what happens
    # when the PaymentIntent is successful.
    PaymentIntent.create!(
      square_location_id: square_location_id,
      square_payment_id: payment[:id],
      email: email,
      line_items: line_items.to_json,
      receipt_url: receipt_url
    )

    api_response
  end

  def create_stripe_payment_request(amount:, email:, description:, line_items:)
    Stripe.api_key = ENV['STRIPE_API_KEY']

    intent = Stripe::PaymentIntent.create(
      amount: amount,
      currency: 'usd',
      receipt_email: email,
      payment_method_types: ['card'],
      description: description
    )

    # Creates a pending PaymentIntent. See webhooks_controller to see what happens
    # when the PaymentIntent is successful.
    PaymentIntent.create!(
      stripe_id: intent['id'],
      email: email,
      line_items: line_items.to_json
    )

    intent
  end
end
