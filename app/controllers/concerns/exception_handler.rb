# frozen_string_literal: true

module ExceptionHandler
  class InvalidLineItem < StandardError; end
  class InvalidGiftCardUpdate < StandardError; end
  class CannotGenerateUniqueHash < StandardError; end
  class InvalidSquareSignature < StandardError; end
  class DuplicateChargeError < StandardError; end
  class DuplicatePaymentCompletedError < StandardError; end
  class SquarePaymentsError < StandardError
    attr_reader :status_code
    attr_reader :errors

    def initialize(errors:, status_code:)
      @status_code = status_code
      @errors = errors
      # Get the first error and give the detail of it as a message
      super(errors.first[:detail].to_s)
    end
  end

  # provides the more graceful `included` method
  extend ActiveSupport::Concern

  # Note that these are evaluated from bottom to top
  included do
    rescue_from ActiveRecord::RecordInvalid,
                ActionController::ParameterMissing,
                InvalidLineItem,
                InvalidGiftCardUpdate do |e|
      json_response({ message: e.message }, :unprocessable_entity)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: e.message }, :not_found)
    end

    rescue_from JSON::ParserError do |e|
      json_response({ message: e.error.message }, :bad_request)
    end

    rescue_from Stripe::StripeError do |e|
      json_response({ message: e.error.message }, e.http_status)
    end

    rescue_from DuplicateChargeError,
                DuplicatePaymentCompletedError do |e|
      json_response({ message: e.message }, :bad_request)
    end

    # Invalid signature
    rescue_from InvalidSquareSignature do |e|
      json_response({ message: e.message }, :bad_request)
    end

    rescue_from SquarePaymentsError do |e|
      json_response({
                      # Give the detail of the first error
                      message: e.message,
                      type: 'SQUARE_PAYMENTS_ERROR',
                      errors: e.errors
                    }, e.status_code)
    end
  end
end
