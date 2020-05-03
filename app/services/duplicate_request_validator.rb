# frozen_string_literal: true

# Validates idempotency using the ExistingEvent Model
class DuplicateRequestValidator < BaseService
  attr_reader :idempotency_key, :event_type

  def initialize(params)
    @idempotency_key = params[:idempotency_key]
    @event_type = params[:event_type]
  end

  def call
    existing_event = ExistingEvent.new(
      idempotency_key: idempotency_key,
      event_type: event_type
    )

    unless existing_event.save
      Rails.logger.info "Not idempotent idempotency_key: #{idempotency_key};"\
                        " event_type: #{event_type}"
      raise ExceptionHandler::DuplicateRequestError,
        'Request was already received'
    end
  end
end
