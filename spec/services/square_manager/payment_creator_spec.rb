# frozen_string_literal: true

require 'rails_helper'

describe SquareManager::PaymentCreator, '#call' do
  let(:square_client) { instance_double(Square::Client) }
  let(:payments) { instance_double(Square::PaymentsApi) }
  let(:response) { double(Square::ApiResponse) }
  let(:create_payment_body) do
    {
      nonce: 'abc',
      amount: 100,
      email: 'example@email.com',
      note: 'abcd',
      location_id: 'location-id'
    }
  end

  it 'creates payment' do
    # Setup
    expect(Square::Client).to receive(:new).with(any_args).and_return(
      square_client
    )
    expect(square_client).to receive(:payments).and_return(payments)
    expect(payments).to receive(:create_payment).with(any_args).and_return(
      response
    )

    # Expect
    expect(SquareManager::PaymentCreator.call(create_payment_body)).to equal(
      response
    )
  end
end
