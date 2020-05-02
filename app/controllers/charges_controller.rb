# frozen_string_literal: true

require 'securerandom'

class ChargesController < ApplicationController
  # POST /charges
  def create
    line_items = charge_params[:line_items].map(&:to_h)

    seller_id = charge_params[:seller_id]

    validate(seller_id: seller_id, line_items: line_items)

    # Validate each Item and get all ItemTypes
    item_types = Set.new
    line_items.each do |item|
      item_types.add item['item_type']
      item[:seller_id] = seller_id
    end

    seller = Seller.find_by(seller_id: seller_id)

    # Total all Items
    amount =
      line_items.inject(0) do |sum, item|
        sum + item['amount'] * item['quantity']
      end

    description =
      generate_description(seller_name: seller.name, item_types: item_types)

    email = charge_params[:email]
    payment =
      if charge_params[:is_square]
        create_square_payment_request(
          nonce: charge_params[:nonce],
          amount: amount,
          note: description,
          email: email,
          name: charge_params[:name],
          seller: seller,
          line_items: line_items
        )
      else
        create_stripe_payment_request(
          amount: amount,
          email: email,
          description: description,
          line_items: line_items
        )
      end

    json_response(payment)
  end

  private

  def charge_params
    params.require(:seller_id)
    params.require(:line_items)
    params.require(:email)
    params.require(:is_square)
    params.require(:nonce) if params[:is_square]
    params.require(:name)
    params.permit(
      :email,
      :nonce,
      :is_square,
      :name,
      :seller_id,
      line_items: [%i[amount currency item_type quantity]]
    )
  end

  def validate(seller_id:, line_items:)
    unless Seller.find_by(seller_id: seller_id).present?
      raise InvalidLineItem, "Seller does not exist: #{seller_id}"
    end

    line_items.each do |line_item|
      %i[amount currency item_type quantity].each do |attribute|
        unless line_item.key?(attribute)
          raise ActionController::ParameterMissing,
                "param is missing or the value is empty: #{attribute}"
        end
      end

      unless %w[gift_card donation].include? line_item['item_type']
        raise InvalidLineItem,
              'line_item must be named `gift_card` or `donation`'
      end

      unless line_item['amount'].is_a? Integer
        raise InvalidLineItem, 'line_item.amount must be an Integer'
      end

      unless line_item['quantity'].is_a? Integer
        raise InvalidLineItem, 'line_item.quantity must be an Integer'
      end

      amount = line_item['amount']
      unless amount >= 50
        raise InvalidLineItem, 'Amount must be at least $0.50 usd'
      end
    end
  end

  def generate_description(seller_name:, item_types:)
    description = 'Thank you for supporting ' + seller_name + '.'
    if item_types.include? 'gift_card'
      description += ' Your gift card(s) will be emailed'\
                     ' to you when the seller opens back up.'
    end

    description
  end

  def create_square_payment_request(
    nonce:, amount:, note:, email:, name:, seller:, line_items:
  )
    square_location_id = seller.square_location_id

    api_response =
      SquareManager::PaymentCreator.call(
        {
          nonce: nonce,
          amount: amount,
          email: email,
          note: note,
          location_id: square_location_id
        }
      )

    errors = api_response.errors
    if errors.present?
      raise SquarePaymentsError.new(
        errors: errors, status_code: api_response.status_code
      )
    end

    payment = api_response.data.payment
    receipt_url = payment[:receipt_url]

    # Creates a pending PaymentIntent. See webhooks_controller to see what
    # happens when the PaymentIntent is successful.
    PaymentIntent.create!(
      square_location_id: square_location_id,
      square_payment_id: payment[:id],
      email: email,
      line_items: line_items.to_json,
      receipt_url: receipt_url,
      name: name
    )

    api_response
  end

  def create_stripe_payment_request(amount:, email:, description:, line_items:)
    Stripe.api_key = ENV['STRIPE_API_KEY']

    intent =
      Stripe::PaymentIntent.create(
        amount: amount,
        currency: 'usd',
        receipt_email: email,
        payment_method_types: %w[card],
        description: description
      )

    # Creates a pending PaymentIntent. See webhooks_controller to see what
    # happens when the PaymentIntent is successful.
    PaymentIntent.create!(
      stripe_id: intent['id'], email: email, line_items: line_items.to_json
    )

    intent
  end
end
