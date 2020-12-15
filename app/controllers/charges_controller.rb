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
    project_id = charge_params[:project_id]

    validate(
      seller_id: seller_id,
      project_id: project_id,
      line_items: line_items,
      is_distribution: charge_params[:is_distribution]
    )

    # Validate each Item and get all ItemTypes
    item_types = Set.new
    line_items.each do |item|
      item_types.add item['item_type']
      item[:seller_id] = seller_id if seller_id.present?
      item[:project_id] = project_id if project_id.present?
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
                                            line_items: line_items,
                                            metadata: charge_params[:metadata],
                                            project_id: project_id)

    # Save the contact information only if the charge is succesful
    # Use a job to avoid blocking the request
    ContactRegistrationJob.perform_now(name: charge_params[:name],
                                       email: charge_params[:email],
                                       is_subscribed: charge_params[:is_subscribed])

    json_response(payment)
  end

  private

  def charge_params
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
      :project_id,
      :idempotency_key,
      :is_subscribed,
      :campaign_id,
      # TODO(justintmckibben): Deprecate this boolean in favor of campaign_id
      :is_distribution,
      :metadata,
      line_items: [%i[amount currency item_type quantity]]
    )
  end

  def validate(seller_id:, project_id:, line_items:, is_distribution:)
    @seller = Seller.find_by(seller_id: seller_id)
    @project = Project.find_by(id: project_id)

    unless @seller.present? ^ @project.present?
      raise InvalidLineItem, "Project or Seller must exist, but not both. seller id: #{seller_id}, project_id: #{project_id}"
    end

    line_items.each do |line_item|
      %i[amount currency item_type quantity].each do |attribute|
        unless line_item.key?(attribute)
          raise ActionController::ParameterMissing,
                "param is missing or the value is empty: #{attribute}"
        end
      end

      unless %w[gift_card donation transaction_fee].include? line_item['item_type']
        raise InvalidLineItem,
              'line_item must be named `gift_card`, `donation`, or `transaction_fee`'
      end

      unless line_item['amount'].is_a? Integer
        raise InvalidLineItem, 'line_item.amount must be an Integer'
      end

      unless line_item['quantity'].is_a? Integer
        raise InvalidLineItem, 'line_item.quantity must be an Integer'
      end

      @campaign = if is_distribution.present?
                    # TODO(justintmckibben): Delete this case when we start using campaign_id
                    #                        in the frontend
                    campaign = Campaign.find_by(
                      seller_id: @seller.id,
                      active: true,
                      valid: true
                    )
                    unless campaign
                      raise ActiveRecord::RecordNotFound, "Passed in is_distribution with no active campaign running for seller_id=#{seller_id}"
                    end

                    campaign
                  elsif charge_params[:campaign_id].present?
                    Campaign.find_by(campaign_id: campaign_id)
                  end

      amount = line_item['amount']

      unless gift_a_meal? && @seller.cost_per_meal.present? && amount % @seller.cost_per_meal != 0
        next
      end

      raise InvalidGiftAMealAmountError,
            "Gift A Meal amount '#{amount}' must be divisible by seller's "\
            "cost per meal '#{@seller.cost_per_meal}'."
    end

    total_amount = line_items.sum { |li| li['amount'].to_i }

    unless total_amount >= 50
      raise InvalidLineItem, 'Amount must be at least $0.50 usd'
    end
  end

  def create_square_payment_request(
    nonce:,
    amount:,
    email:,
    name:,
    line_items:,
    metadata:,
    project_id:
  )
    square_location_id = if gift_a_meal? && @seller.non_profit_location_id.present?
                           @seller.non_profit_location_id
                         elsif @project.present?
                           @project.square_location_id
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
    
    # Check for whether a campaign exits. If a campaign exists, then check whether the campaign has a non-profit associated with it. 
    # If a non-profit exists, then check whether the non-profit has a fee ID. If so, then set fee ID equal to fee_id
    fee_id = if @campaign && @campaign[:nonprofit_id] && Nonprofit.find_by(id: @campaign[:nonprofit_id])[:fee_id]
              Fee.find_by(id: Nonprofit.find_by(id: @campaign[:nonprofit_id])[:fee_id])[:id]
             end

    PaymentIntent.create!(
      square_location_id: square_location_id,
      square_payment_id: payment[:id],
      line_items: line_items.to_json,
      receipt_url: receipt_url,
      purchaser: purchaser,
      recipient: recipient,
      campaign: @campaign,
      metadata: metadata,
      project: Project.find_by(id: project_id),
      fee_id: fee_id
    )

    api_response
  end

  def gift_a_meal?
    @campaign.present?
  end
end
