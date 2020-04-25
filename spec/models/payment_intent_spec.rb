# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentIntent, type: :model do
  it { should validate_uniqueness_of(:stripe_id) }
  it { should validate_uniqueness_of(:square_payment_id) }
  it { should have_many(:items) }

  context 'with square payment intent' do
    let(:payment_intent) do
      create(
        :square_payment_intent,
        square_payment_id: 'square-id',
        square_location_id: square_location_id
      )
    end
    let(:square_location_id) { 'OIJWEOIFJEOIFJ' }

    it 'lets you create a payment intent with square_payment_id' do
      expect(PaymentIntent.where(id: payment_intent.id).empty?).to eq(false)
    end

    context 'without square_location_id' do
      let(:square_location_id) { nil }

      it 'does not let you create a square payment intent without a location' do
        expect do
          payment_intent
        end.to raise_error(
          ActiveRecord::RecordInvalid,
          'Validation failed: Square location must exist if square_payment_id exists'
        )
      end
    end
  end

  context 'with stripe payment intent' do
    let(:payment_intent) do
      create(
        :stripe_payment_intent,
        stripe_id: 'stripe-id'
      )
    end

    it 'lets you create a payment intent with stripe_id' do
      expect(PaymentIntent.where(id: payment_intent.id).empty?).to eq(false)
    end
  end

  context 'with both stripe and square id' do
    let(:payment_intent) do
      create(
        :payment_intent,
        stripe_id: 'stripe-id',
        square_payment_id: 'square-id',
        square_location_id: 'OIJWEOFIJWEFE'
      )
    end

    it 'does not let you create a payment intent' do
      expect do
        payment_intent
      end.to raise_error(
        ActiveRecord::RecordInvalid,
        'Validation failed: Stripe cannot contain both stripe_id and square_payment_id, Square payment cannot contain both stripe_id and square_payment_id'
      )
    end
  end

  context 'with neither stripe nor square id' do
    let(:payment_intent) { create :payment_intent, stripe_id: nil, square_payment_id: nil }
    it 'does not let you create a payment intent' do
      expect do
        payment_intent
      end.to raise_error(
        ActiveRecord::RecordInvalid,
        'Validation failed: Stripe must contain either stripe_id or square_payment_id, Square payment must contain either stripe_id or square_payment_id'
      )
    end
  end
end
