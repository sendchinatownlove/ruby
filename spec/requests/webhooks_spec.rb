require 'rails_helper'

RSpec.describe 'Webhooks API', type: :request do
  before { freeze_time }

  # Test suite for POST /webhooks
  describe 'POST /webhooks' do
    let(:line_items) do
      [{
        'amount': 5000,
        'currency': 'usd',
        'item_type': item_type,
        'quantity': 1,
        'seller_id': seller.seller_id
      }].to_json
    end
    let(:payment_intent) do
      create(
        :payment_intent,
        stripe_id: SecureRandom.uuid,
        line_items: line_items
      )
    end
    let(:seller) { create :seller }
    let(:payment_intent_response) do
      {
        'id': payment_intent.stripe_id,
        'receipt_email': payment_intent.email,
      }
    end

    let(:payload) do
      {
        'type': 'payment_intent.succeeded',
        'data': {
          'object': payment_intent_response
        }
      }
    end

    before do
      create :seller
      allow(SecureRandom).to receive(:hex)
        .and_return('abcdef123')
      allow(SecureRandom).to receive(:uuid)
        .and_return('aweofijn-3n3400-oawjiefwef-0iawef-0i')
      allow(Stripe::Webhook).to receive(:construct_event)
        .and_return(payload.with_indifferent_access)
      post '/webhooks', headers: { 'HTTP_STRIPE_SIGNATURE' => 'www.stripe.com' }
    end

    context 'with donation' do
      let(:item_type) { 'donation' }

      it 'creates a donation' do
        donation_detail = DonationDetail.last
        expect(donation_detail).not_to be_nil
        expect(donation_detail['amount']).to eq(5000)

        item = Item.find(donation_detail['item_id'])
        expect(item).not_to be_nil
        expect(item['email']).to eq(payment_intent.email)
        expect(item.donation?).to be true
        expect(item.seller).to eq(seller)

        payment_intent = PaymentIntent.find(item['payment_intent_id'])
        expect(payment_intent.successful).to be true
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      context 'with duplicate call' do
        before do
          post '/webhooks', headers: { 'HTTP_STRIPE_SIGNATURE' => 'www.stripe.com' }
        end

        it 'returns status code 400' do
          expect(response.body)
                .to match(/This payment has already been received as COMPLETE payment_intent.id: #{payment_intent.id}/)
          expect(response).to have_http_status(400)
        end
      end
    end

    context 'with gift card' do
      let(:item_type) { 'gift_card' }

      it 'creates a gift card' do
        gift_card_detail = GiftCardDetail.last
        expect(gift_card_detail).not_to be_nil
        expect(gift_card_detail.gift_card_id).to eq('aweofijn-3n3400-oawjiefwef-0iawef-0i')
        expect(gift_card_detail.seller_gift_card_id).to eq('#ABC-DE')
        expect(gift_card_detail.expiration).to eq(Date.today + 1.year)

        gift_card_amount = GiftCardAmount.find_by(
          gift_card_detail_id: gift_card_detail['id']
        )
        expect(gift_card_amount['value']).to eq(5000)

        item = Item.find(gift_card_detail['item_id'])
        expect(item).not_to be_nil
        expect(item.gift_card?).to be true
        expect(item.seller).to eq(seller)
        expect(item['email']).to eq(payment_intent.email)

        payment_intent = PaymentIntent.find(item['payment_intent_id'])
        expect(payment_intent.successful).to be true
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      context 'with duplicate call' do
        before do
          post '/webhooks', headers: { 'HTTP_STRIPE_SIGNATURE' => 'www.stripe.com' }
        end

        it 'returns status code 400' do
          expect(response.body)
                .to match(/This payment has already been received as COMPLETE payment_intent.id: #{payment_intent.id}/)
          expect(response).to have_http_status(400)
        end
      end
    end
  end
end
