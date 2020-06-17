# frozen_string_literal: true

require 'rails_helper'

describe DuplicateRequestValidator, '#call' do
  let(:existing_event) do
    create(:existing_event, :webhook)
  end

  it 'is duplicate' do
    expect do
      DuplicateRequestValidator.call({
                                       idempotency_key: existing_event.idempotency_key,
                                       event_type: existing_event.event_type
                                     })
    end.to raise_error(ExceptionHandler::DuplicateRequestError)
  end

  it 'is not duplicate' do
    DuplicateRequestValidator.call({
                                     idempotency_key: 1,
                                     event_type: 'payment_updated'
                                   })
  end
end
