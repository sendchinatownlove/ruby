# frozen_string_literal: true

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
        square_payment_id: SecureRandom.uuid,
        square_location_id: SecureRandom.uuid,
        line_items: line_items
      )
    end
    let(:seller) { create :seller }
    let(:payment_intent_response) do
      {
        'payment': {
          'id': payment_intent.square_payment_id,
          'location_id': payment_intent.square_location_id,
          'receipt_email': payment_intent.email,
          'status': 'COMPLETED'
        }
      }
    end

    let(:payload) do
      {
        'event_id': 'abcd-1234',
        'type': 'payment.updated',
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
      allow(Digest::SHA1).to receive(:base64digest)
        .and_return(true)

      post(
        '/webhooks',
        headers: { 'HTTP_X_SQUARE_SIGNATURE' => 'www.squareup.com' },
        params: payload.to_json
      )
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

      context 'with refund' do
        let(:refund_response) do
          {
            'refund': {
              'id': SecureRandom.uuid,
              'payment_id': payment_intent.square_payment_id,
              'status': status
            }
          }
        end

        let(:refund_payload) do
          {
            'event_id': 'dfgh-4567',
            'type': payload_type,
            'data': {
              'object': refund_response
            }
          }
        end

        before do
          post(
            '/webhooks',
            headers: { 'HTTP_X_SQUARE_SIGNATURE' => 'www.squareup.com' },
            params: refund_payload.to_json
          )
        end

        context 'refund.created' do
          let(:payload_type) { 'refund.created' }
          let(:status) { 'PENDING' }

          it 'creates a refund' do
            refund = Refund.last

            expect(refund).not_to be_nil
            expect(refund.status).to eq(status)
            expect(refund.square_refund_id).to eq(
              refund_response[:refund][:id]
            )
            expect(refund.payment_intent_id).to eq(payment_intent.id)
          end

          context 'refund.updated' do
            before do
              post(
                '/webhooks',
                headers: { 'HTTP_X_SQUARE_SIGNATURE' => 'www.squareup.com' },
                params: {
                  'event_id': 'hjkl-1234',
                  'type': 'refund.updated',
                  'data': {
                    'object': {
                      'refund': {
                        'id': SecureRandom.uuid,
                        'payment_id': payment_intent.square_payment_id,
                        'status': updated_status
                      }
                    }
                  }
                }.to_json
              )
            end

            context 'COMPLETED' do
              let(:updated_status) { 'COMPLETED' }

              it 'updates the status' do
                refund = Refund.last

                expect(refund).not_to be_nil
                expect(refund.status).to eq(updated_status)
              end

              it 'refunds all of the items' do
                Refund.last.payment_intent.items.all do |item|
                  expect(item.refunded).to eq(true)
                end
              end
            end

            context 'FAILED' do
              let(:updated_status) { 'FAILED' }

              it 'updates the status' do
                refund = Refund.last

                expect(refund).not_to be_nil
                expect(refund.status).to eq(updated_status)
              end

              it "doesn't refund all of the items" do
                Refund.last.payment_intent.items.all do |item|
                  expect(item.refunded).to eq(false)
                end
              end
            end
          end
        end
      end

      context 'with duplicate call' do
        before do
          post(
            '/webhooks',
            headers: { 'HTTP_X_SQUARE_SIGNATURE' => 'www.squareup.com' },
            params: payload.to_json
          )
        end

        it 'returns status code 400' do
          expect(response.body)
            .to match(
              /Request was already received/
            )

          expect(response).to have_http_status(409)
        end
      end
    end

    context 'with gift card' do
      let(:item_type) { 'gift_card' }

      it 'creates a gift card' do
        gift_card_detail = GiftCardDetail.last
        expect(gift_card_detail).not_to be_nil
        expect(gift_card_detail.gift_card_id).to eq(
          'aweofijn-3n3400-oawjiefwef-0iawef-0i'
        )
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
          post(
            '/webhooks',
            headers: { 'HTTP_X_SQUARE_SIGNATURE' => 'www.squareup.com' },
            params: payload.to_json
          )
        end

        it 'returns status code 400' do
          expect(response.body)
            .to match(
              /Request was already received/
            )

          expect(response).to have_http_status(409)
        end
      end
    end
  end
end
