# frozen_string_literal: true

require 'rails_helper'

describe SquareManager::WebhookValidator, '#call' do
  it 'is valid webhook' do
    string_signature = 'string_signature'
    callback_signature = 'callback_signature'

    expect(Base64).to receive(:strict_encode64).with(any_args).and_return(
      string_signature
    )
    expect(Digest::SHA1).to receive(:base64digest).with(
      string_signature
    ).and_return(true)
    expect(Digest::SHA1).to receive(:base64digest).with(
      callback_signature
    ).and_return(true)

    SquareManager::WebhookValidator.call({
      url: 'example.com/webhooks',
      callback_body: '{}',
      callback_signature: callback_signature
    })
  end

  it 'is not valid webhook' do
    expect {
      SquareManager::WebhookValidator.call({
        url: 'example.com/webhooks',
        callback_body: '{}',
        callback_signature: 'abc'
      })
    }.to raise_error(ExceptionHandler::InvalidSquareSignature)
  end
end
