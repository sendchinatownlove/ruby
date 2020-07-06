# frozen_string_literal: true

require 'rails_helper'

describe SquareManager::PaymentCreator do
  describe '#call' do
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

  describe '#access_token_from_location_id' do
    let(:init_data) do
      {
        nonce: 'abc',
        amount: 100,
        email: 'example@email.com',
        note: 'abcd',
        location_id: 'location-id'
      }
    end

    it 'returns the right access tokens for the the right location ids' do
      # Arrange
      tc_lid = 'tc_lid'
      tc_at = 'tc_at'
      our_at = 'our_at'

      allow(ENV).to receive(:[]).with('THINK_CHINATOWN_LOCATION_ID').and_return(tc_lid)
      allow(ENV).to receive(:[]).with('THINK_CHINATOWN_ACCESS_TOKEN').and_return(tc_at)
      allow(ENV).to receive(:[]).with('SQUARE_ACCESS_TOKEN').and_return(our_at)

      pc = SquareManager::PaymentCreator.new(init_data)

      # Act
      access_token = pc.send('access_token_from_location_id', location_id: tc_lid)
      access_token2 = pc.send('access_token_from_location_id', location_id: 'anything else')

      # Assert
      expect(access_token).to equal(tc_at)
      expect(access_token2).to equal(our_at)
    end
  end
end
