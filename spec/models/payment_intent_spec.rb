# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_intents
#
#  id                 :bigint           not null, primary key
#  line_items         :text
#  lock_version       :integer
#  metadata           :text
#  origin             :string           default("square"), not null
#  receipt_url        :string
#  successful         :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  campaign_id        :bigint
#  fee_id             :bigint
#  project_id         :bigint
#  purchaser_id       :bigint
#  recipient_id       :bigint
#  square_location_id :string
#  square_payment_id  :string
#
# Indexes
#
#  index_payment_intents_on_campaign_id   (campaign_id)
#  index_payment_intents_on_fee_id        (fee_id)
#  index_payment_intents_on_project_id    (project_id)
#  index_payment_intents_on_purchaser_id  (purchaser_id)
#  index_payment_intents_on_recipient_id  (recipient_id)
#
# Foreign Keys
#
#  fk_rails_...  (campaign_id => campaigns.id)
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (purchaser_id => contacts.id)
#  fk_rails_...  (recipient_id => contacts.id)
#
require 'rails_helper'

RSpec.describe PaymentIntent, type: :model do
  context 'when payment_intent origin is from square' do
    context('with square_location_id') do
      it { should validate_presence_of(:origin) }
      it { should validate_presence_of(:square_location_id) }
      it { should validate_presence_of(:square_payment_id) }
      it { should validate_uniqueness_of(:square_payment_id) }
      it { should have_many(:items) }
      it { should belong_to(:purchaser) }
      it { should belong_to(:recipient).optional }

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

      context 'with line_items' do
        let!(:payment_intent) do
          create(
            :payment_intent,
            :with_line_items,
            square_payment_id: 'square-id',
            square_location_id: square_location_id
          )
        end

        it 'should add each line item and return the correct total' do
          expect(payment_intent.amount).to eq(600)
        end
      end

      context 'without line_items' do
        it 'should return 0 as total' do
          expect(payment_intent.amount).to eq(0)
        end
      end
    end

    context 'without square_location_id or square_payment_id' do
      let(:payment_intent) do
        create(
          :payment_intent,
          origin: PaymentIntent::SQUARE,
          square_payment_id: nil,
          square_location_id: nil
        )
      end

      it 'does not let you create a square payment intent' do
        expect do
          payment_intent
        end.to raise_error(
                 ActiveRecord::RecordInvalid,
                 'Validation failed: Square payment can\'t be blank, Square location can\'t be blank'
               )
      end
    end
  end

  context 'when payment_intent origin is not from square' do
    let!(:payment_intent) do
      create(
        :payment_intent,
        origin: PaymentIntent::CUSTOM,
        square_payment_id: nil,
        square_location_id: nil
      )
    end

    it 'should create a payment with a payment_intent' do
      expect(PaymentIntent.where(id: payment_intent.id).empty?).to eq(false)
    end
  end

  context 'turn off campaign if goal is reached' do
    it 'turns the campaign inactive if the campaign is associated with a project ' do
      project = create(:project)
      campaign = create(:campaign, active: true, project_id: project.id, target_amount: 10_000, seller_id: nil)
      expect(campaign.active).to eq(true)

      line_items =  '[
        { "amount": 10000, "project_id": 1, "item_type": "donation" },
        { "amount": 314, "project_id": 1, "item_type": "transaction_fee" }
      ]'
      payment_intent = create(:payment_intent, line_items: line_items, campaign_id: campaign.id, project_id: project.id, successful: true)

      expect(Campaign.find(campaign.id).active).to eq(false)
    end
  end
end
