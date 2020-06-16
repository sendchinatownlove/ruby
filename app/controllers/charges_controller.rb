# frozen_string_literal: true

require 'securerandom'

class ChargesController < ApplicationController
  # POST /charges
  def create
    # Validate this not a duplicate charge
    DuplicateRequestValidator.call({
                                     idempotency_key: charge_params[:idempotency_key],
                                     event_type: 'charges_create'
                                   })

    line_items = charge_params[:line_items].map(&:to_h)

    seller_id = charge_params[:seller_id]

    validate(seller_id: seller_id, line_items: line_items)

    is_distribution = charge_params[:is_distribution] || false

    # Validate each Item and get all ItemTypes
    item_types = Set.new
    line_items.each do |item|
      item_types.add item['item_type']
      item[:seller_id] = seller_id
      item[:is_distribution] = is_distribution
    end

    seller = Seller.find_by(seller_id: seller_id)

    # Total all Items
    amount =
      line_items.inject(0) do |sum, item|
        sum + item['amount'] * item['quantity']
      end

    email = charge_params[:email]
    payment = create_square_payment_request(nonce: charge_params[:nonce],
                                            amount: amount,
                                            email: email,
                                            name: charge_params[:name],
                                            seller: seller,
                                            line_items: line_items,
                                            is_distribution: is_distribution)

    # Save the contact information only if the charge is succesful
    # Use a job to avoid blocking the request
    ContactRegistrationJob.perform_now(name: charge_params[:name],
                                       email: charge_params[:email],
                                       is_subscribed: charge_params[:is_subscribed])

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
    params.require(:idempotency_key)
    params.require(:is_subscribed)
    params.permit(
      :email,
      :nonce,
      :is_square,
      :name,
      :seller_id,
      :idempotency_key,
      :is_subscribed,
      :is_distribution,
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

  def create_square_payment_request(
    nonce:, amount:, email:, name:, seller:, line_items:, is_distribution:
  )
    if is_distribution && seller.non_profit_location_id
      square_location_id = seller.non_profit_location_id
    else
      square_location_id = seller.square_location_id
    end

    api_response =
      SquareManager::PaymentCreator.call(
        {
          nonce: nonce,
          amount: amount,
          email: email,
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

    purchaser = Contact.find_or_create_by(email: email)

    if purchaser.name != name
      purchaser.name = name
      purchaser.save!
    end

    recipient = is_distribution ? seller.distributor : purchaser

    # Creates a pending PaymentIntent. See webhooks_controller to see what
    # happens when the PaymentIntent is successful.
    PaymentIntent.create!(
      square_location_id: square_location_id,
      square_payment_id: payment[:id],
      line_items: line_items.to_json,
      receipt_url: receipt_url,
      purchaser: purchaser,
      recipient: recipient
    )

    api_response
  end
end
