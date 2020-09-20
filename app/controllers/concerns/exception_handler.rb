# frozen_string_literal: true

module ExceptionHandler
  class DuplicateRequestError < StandardError; end
  class InvalidParameterError < StandardError; end
  class InvalidLineItem < StandardError; end
  class InvalidGiftCardUpdate < StandardError; end
  class CannotGenerateUniqueHash < StandardError; end
  class InvalidSquareSignature < StandardError; end
  class DuplicatePaymentCompletedError < StandardError; end
  class InvalidPoolDonationError < StandardError; end
  class InvalidGiftAMealAmountError < StandardError; end
  class InvalidLyftRewardsContactError < StandardError; end
  class TicketRedemptionError < StandardError; end
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
                ActiveRecord::StaleObjectError,
                ActionController::ParameterMissing,
                InvalidParameterError,
                InvalidLineItem,
                InvalidLyftRewardsContactError,
                InvalidGiftCardUpdate,
                InvalidGiftAMealAmountError,
                InvalidPoolDonationError do |e|
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

    rescue_from DuplicateRequestError,
                DuplicatePaymentCompletedError do |e|
      json_response({ message: e.message }, :conflict)
    end

    rescue_from InvalidSquareSignature,
                TicketRedemptionError do |e|
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
