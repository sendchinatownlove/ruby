
module ExceptionHandler
  class InvalidLineItem < StandardError; end

  # provides the more graceful `included` method
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: e.message }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid, ActionController::ParameterMissing, InvalidLineItem do |e|
      json_response({ message: e.message }, :unprocessable_entity)
    end

    rescue_from Stripe::StripeError do |e|
      json_response({ message: e.error.message }, e.http_status)
    end
  end
end
