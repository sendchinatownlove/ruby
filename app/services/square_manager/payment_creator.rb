# frozen_string_literal: true

module SquareManager
  class PaymentCreator < BaseService
    attr_reader :nonce, :amount, :email, :note, :location_id

    def initialize(params)
      @nonce = params[:nonce]
      @amount = params[:amount]
      @email = params[:email]
      @note = params[:note]
      @location_id = params[:location_id]
    end

    def call
      client = Square::Client.new(
        access_token: which_access_token_from_location_id(location_id: location_id),
        environment: Rails.env.production? ? 'production' : 'sandbox'
      )
      client.payments.create_payment(body: create_payment_body)
    end

    private

    def create_payment_body
      {
        source_id: nonce,
        idempotency_key: SecureRandom.uuid,
        amount_money: { amount: amount, currency: 'USD' },
        buyer_email_address: email,
        note: note,
        location_id: location_id
      }
    end

    def which_access_token_from_location_id(location_id:)
      case location_id
      when ENV['THINK_CHINATOWN_LOCATION_ID']
        ENV['THINK_CHINATOWN_ACCESS_TOKEN']
      else
        ENV['SQUARE_ACCESS_TOKEN']
      end
    end
  end
end
