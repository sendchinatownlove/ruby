# frozen_string_literal: true

# Validates pool donation types
class PoolDonationValidator < BaseService
  attr_reader :type

  def initialize(params)
    @type = params[:type]
  end

  def call
    unless type.eql?('donation')
      raise ExceptionHandler::InvalidPoolDonationError,
            "pool contribution must but be of type 'donation' " \
            "but found type '#{type}'."
    end
  end
end
