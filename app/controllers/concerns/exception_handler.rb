
module ExceptionHandler
  class InvalidLineItem < StandardError; end
  class InvalidGiftCardUpdate < StandardError; end

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

    # Invalid signature
    rescue_from Stripe::SignatureVerificationError do |e|
      json_response({ message: e.error.message }, e.http_status)
    end

  end
end
