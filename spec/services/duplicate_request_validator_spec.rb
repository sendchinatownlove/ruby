# frozen_string_literal: true

require 'rails_helper'

describe DuplicateRequestValidator, '#call' do

  let(:existing_event) {
    create(:existing_event, :webhook)
  }

  it 'is duplicate' do
    expect {
      DuplicateRequestValidator.call({
        idempotency_key: existing_event.idempotency_key,
        event_type: existing_event.event_type
      })
    }.to raise_error(ExceptionHandler::DuplicateRequestError)
  end

  it 'is not duplicate' do
    DuplicateRequestValidator.call({
      idempotency_key: 1,
      event_type: 'payment_updated'
    })
  end
end
