# frozen_string_literal: true

# Validates HMAC-SHA1 signatures included in webhook notifications to ensure
# notifications came from Square
module SquareManager
  class WebhookValidator < BaseService
    attr_reader :url, :callback_body, :callback_signature

    def initialize(params)
      @url = params[:url]
      @callback_body = params[:callback_body]
      @callback_signature = params[:callback_signature]
    end

    def call
      string_to_sign = url + callback_body

      # Generate the HMAC-SHA1 signature of the string, signed with your webhook
      # signature key
      accounts = %w[square think_chinatown apex]
      signatures = accounts.map do |account_name|
        Base64.strict_encode64(
          OpenSSL::HMAC.digest(
            'sha1',
            ENV["#{account_name.upcase}_WEBHOOK_SIGNATURE_KEY"],
            string_to_sign
          )
        )
      end

      # Hash the signatures a second time (to protect against timing attacks)
      # and compare them
      hashed_signatures = signatures.map { |signature| Digest::SHA1.base64digest(signature) }

      unless hashed_signatures.include?(Digest::SHA1.base64digest(callback_signature))
        raise ExceptionHandler::InvalidSquareSignature
      end
    end
  end
end
