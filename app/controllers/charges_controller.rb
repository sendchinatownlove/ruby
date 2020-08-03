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

    validate(
      seller_id: seller_id,
      line_items: line_items,
      is_distribution: charge_params[:is_distribution]
    )

    # Validate each Item and get all ItemTypes
    item_types = Set.new
    line_items.each do |item|
      item_types.add item['item_type']
      item[:seller_id] = seller_id
    end


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
                                            line_items: line_items)

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
      :campaign_id,
      # TODO(justintmckibben): Deprecate this boolean in favor of campaign_id
      :is_distribution,
      line_items: [%i[amount currency item_type quantity]]
    )
  end

  def validate(seller_id:, line_items:, is_distribution:)
    @seller = Seller.find_by(seller_id: seller_id)
    unless @seller.present?
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

      @campaign = if is_distribution.present?
        # TODO(justintmckibben): Delete this case when we start using campaign_id
        #                        in the frontend
        Campaign.find_by(
          seller_id: @seller.id,
          active: true,
          valid: true
        )
      elsif charge_params[:campaign_id].present?
        Campaign.find_by(campaign_id: campaign_id)
      end

      if gift_a_meal? && @seller.cost_per_meal.present? && amount % @seller.cost_per_meal != 0
        raise InvalidGiftAMealAmountError,
              "Gift A Meal amount '#{amount}' must be divisible by seller's "\
              "cost per meal '#{@seller.cost_per_meal}'."
      end
    end
  end

  def create_square_payment_request(
    nonce:,
    amount:,
    email:,
    name:,
    line_items:
  )
    square_location_id = if gift_a_meal? && @seller.non_profit_location_id.present?
                           @seller.non_profit_location_id
                         else
                           @seller.square_location_id
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

    recipient = gift_a_meal? ? @campaign.distributor.contact : purchaser

    # Creates a pending PaymentIntent. See webhooks_controller to see what
    # happens when the PaymentIntent is successful.
    PaymentIntent.create!(
      square_location_id: square_location_id,
      square_payment_id: payment[:id],
      line_items: line_items.to_json,
      receipt_url: receipt_url,
      purchaser: purchaser,
      recipient: recipient,
      campaign: @campaign
    )

    api_response
  end

  def gift_a_meal?
    @campaign.present?
  end
end
