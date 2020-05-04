# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_intents
#
#  id                 :bigint           not null, primary key
#  stripe_id          :string
#  email              :string
#  line_items         :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  successful         :boolean          default(FALSE)
#  square_payment_id  :string
#  square_location_id :string
#  email_text         :string
#  receipt_url        :string
#  name               :string
#
require 'rails_helper'

RSpec.describe PaymentIntent, type: :model do
  context('with square_location_id') do
    it { should validate_uniqueness_of(:square_payment_id) }
    it { should validate_presence_of(:square_payment_id) }
    it { should validate_presence_of(:square_location_id) }
    it { should have_many(:items) }

    let!(:payment_intent) do
      create(
        :payment_intent,
        square_payment_id: 'square-id',
        square_location_id: square_location_id
      )
    end
    let(:square_location_id) { 'OIJWEOIFJEOIFJ' }

    it 'lets you create a payment intent with square_payment_id' do
      expect(PaymentIntent.where(id: payment_intent.id).empty?).to eq(false)
    end
  end

  context 'without square_location_id' do
    let(:square_location_id) { nil }
    let(:payment_intent) do
      create(
        :payment_intent,
        square_payment_id: 'square-id',
        square_location_id: square_location_id
      )
    end

    it 'does not let you create a square payment intent without a location' do
      expect do
        payment_intent
      end.to raise_error(
        ActiveRecord::RecordInvalid,
        'Validation failed: Square location can\'t be blank'
      )
    end
  end
end
