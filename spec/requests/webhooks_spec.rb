# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Webhooks API', type: :request do
  before { freeze_time }

  # Test suite for POST /webhooks
  describe 'POST /webhooks' do
    let(:line_items) do
      [{
        'amount': amount,
        'currency': 'usd',
        'item_type': item_type,
        'quantity': 1,
        'seller_id': seller_id
      }].to_json
    end
    let(:purchaser) do
      create(
        :contact,
        seller: Seller.find_by(seller_id: seller_id)
      )
    end
    let(:recipient) do
      create(
        :contact,
        seller: Seller.find_by(seller_id: seller_id)
      )
    end
    let(:payment_intent) do
      create(
        :payment_intent,
        square_payment_id: SecureRandom.uuid,
        square_location_id: SecureRandom.uuid,
        recipient: recipient,
        purchaser: purchaser,
        line_items: line_items
      )
    end
    let!(:seller1) do
      create :seller, seller_id: 'leaky-cauldron', accept_donations: true
    end
    let!(:seller2) do
      create :seller, seller_id: 'honeydukes', accept_donations: true
    end
    let!(:seller3) do
      create :seller, seller_id: 'great-hall', accept_donations: false
    end
    let!(:seller_pool) do
      create :seller, seller_id: Seller::POOL_DONATION_SELLER_ID, accept_donations: false
    end
    let(:payment_intent_response) do
      {
        'payment': {
          'id': payment_intent.square_payment_id,
          'location_id': payment_intent.square_location_id,
          'receipt_email': payment_intent.recipient.email,
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
      allow_any_instance_of(WebhooksController)
        .to receive(:generate_seller_gift_card_id_hash)
        .and_return('abcde')
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

    context 'with pool donation' do
      let(:seller_id) { seller_pool.seller_id }

      def get_donation_detail(seller_id:)
        DonationDetail.joins(:item).where(
          items: { seller_id: seller_id }
        ).first
      end

      context 'with nice pool donation' do
        let(:amount) { 5000 }
        let(:item_type) { 'donation' }

        it 'creates pool donation' do
          donation_to_seller1 = get_donation_detail(seller_id: seller1.id)
          donation_to_seller2 = get_donation_detail(seller_id: seller2.id)
          donation_to_seller3 = get_donation_detail(seller_id: seller3.id)

          expect(DonationDetail.count).to eq(2)
          expect(Item.count).to eq(2)
          expect(PaymentIntent.count).to eq(1)

          expect(donation_to_seller1).not_to be_nil
          expect(donation_to_seller2).not_to be_nil
          expect(donation_to_seller3).to be_nil

          expect(donation_to_seller1.amount).to eq(2500)
          expect(donation_to_seller2.amount).to eq(2500)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'with non-divisible number round' do
        let(:amount) { 3 }
        let(:item_type) { 'donation' }

        it 'creates pool donation and distrubutes the cents' do
          donation_to_seller1 = get_donation_detail(seller_id: seller1.id)
          donation_to_seller2 = get_donation_detail(seller_id: seller2.id)
          donation_to_seller3 = get_donation_detail(seller_id: seller3.id)

          expect(DonationDetail.count).to eq(2)
          expect(Item.count).to eq(2)
          expect(PaymentIntent.count).to eq(1)

          expect(donation_to_seller1).not_to be_nil
          expect(donation_to_seller2).not_to be_nil
          expect(donation_to_seller3).to be_nil

          expect(donation_to_seller1.amount).to eq(2)
          expect(donation_to_seller2.amount).to eq(1)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'with an extra seller' do
        let!(:seller3) do
          create :seller, seller_id: 'great-hall', accept_donations: true
        end

        context 'with non-divisible number round' do
          let(:amount) { 335 }
          let(:item_type) { 'donation' }

          it 'creates pool donation and distrubutes the cents' do
            donation_to_seller1 = get_donation_detail(seller_id: seller1.id)
            donation_to_seller2 = get_donation_detail(seller_id: seller2.id)
            donation_to_seller3 = get_donation_detail(seller_id: seller3.id)

            expect(DonationDetail.count).to eq(3)
            expect(Item.count).to eq(3)
            expect(PaymentIntent.count).to eq(1)

            expect(donation_to_seller1).not_to be_nil
            expect(donation_to_seller2).not_to be_nil
            expect(donation_to_seller2).not_to be_nil

            expect(donation_to_seller1.amount).to eq(112)
            expect(donation_to_seller2.amount).to eq(112)
            expect(donation_to_seller3.amount).to eq(111)
          end

          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end
        end
      end

      context 'with erroneous pool gift card' do
        let(:amount) { 5000 }
        let(:item_type) { 'gift card' }

        it 'returns status code 422' do
          expect(response.body)
            .to match(
              /but found type 'gift card'./
            )

          expect(response).to have_http_status(422)
        end
      end
    end

    context 'with donation' do
      let(:amount) { 5000 }
      let(:item_type) { 'donation' }
      let(:seller_id) { seller1.seller_id }

      it 'creates a donation' do
        donation_detail = DonationDetail.last
        expect(donation_detail).not_to be_nil
        expect(donation_detail['amount']).to eq(5000)

        item = Item.find(donation_detail['item_id'])
        expect(item).not_to be_nil
        expect(item.purchaser).to eq(payment_intent.purchaser)
        expect(item.donation?).to be true
        expect(item.seller).to eq(seller1)

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
      let(:amount) { 5000 }
      let(:item_type) { 'gift_card' }
      let(:seller_id) { seller1.seller_id }

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
        expect(item.seller).to eq(seller1)

        payment_intent = PaymentIntent.find(item['payment_intent_id'])
        expect(payment_intent.successful).to be true
        expect(payment_intent.recipient).not_to eq(payment_intent.purchaser)
        expect(item.purchaser).to eq(payment_intent.purchaser)
        expect(gift_card_detail.recipient).to eq(payment_intent.recipient)
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
