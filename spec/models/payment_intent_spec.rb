require 'rails_helper'

RSpec.describe PaymentIntent, type: :model do
  let(:square_payment_intent) { create :payment_intent, square_payment_id: 'square-id', stripe_id: nil }
  let(:stripe_payment_intent) { create :payment_intent, stripe_id: 'stripe-id', square_payment_id: nil }
  let(:both_payment_intent) { create :payment_intent, stripe_id: 'stripe-id', square_payment_id: 'square-id' }
  let(:neither_payment_intent) { create :payment_intent, stripe_id: nil, square_payment_id: nil }

  it 'lets you create a payment intent with square_payment_id' do
    expect(PaymentIntent.where(id: square_payment_intent.id).empty?).to eq(false)
  end

  it 'lets you create a payment intent with stripe_id' do
    expect(PaymentIntent.where(id: stripe_payment_intent.id).empty?).to eq(false)
  end

  it 'does not let you create a payment intent with both' do
    expect do
      both_payment_intent
    end.to raise_error(
      ActiveRecord::RecordInvalid,
      'Validation failed: Stripe cannot contain both stripe_id and square_payment_id, Square payment cannot contain both stripe_id and square_payment_id'
    )
  end

  it 'does not let you create a payment intent with neither stripe nor square' do
    expect do
      neither_payment_intent
    end.to raise_error(
      ActiveRecord::RecordInvalid,
      'Validation failed: Stripe must contain either stripe_id or square_payment_id, Square payment must contain either stripe_id or square_payment_id'
    )
  end
end
