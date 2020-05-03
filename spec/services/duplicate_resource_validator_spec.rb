# frozen_string_literal: true

require 'rails_helper'

describe DuplicateResourceValidator, '#call' do

  let(:existing_event) {
    create(:existing_event, :webhook)
  }

  it 'is duplicate' do
    expect {
      DuplicateResourceValidator.call({
        idempotency_key: existing_event.idempotency_key,
        event_type: existing_event.event_type
      })
    }.to raise_error(ExceptionHandler::DuplicateResourceError)
  end

  it 'is not duplicate' do
    DuplicateResourceValidator.call({
      idempotency_key: 1,
      event_type: 'payment_updated'
    })
  end
end
