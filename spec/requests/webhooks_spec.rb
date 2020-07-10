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
        'seller_id': seller_id,
        'is_distribution': is_distribution
      }].to_json
    end
    let(:is_distribution) { false }
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
      allow(Digest::SHA1).to receive(:base64digest)
        .and_return(true)

      # Give seller2 the most donations
      item = create(:item, seller: seller2)
      create(:donation_detail, item: item, amount: 10_00)
    end

    describe 'donations' do
      before do
        # Add stub for header verification
        allow(SecureRandom).to receive(:uuid)
          .and_return('aweofijn-3n3400-oawjiefwef-0iawef-0i')
        post(
          '/webhooks',
          headers: { 'HTTP_X_SQUARE_SIGNATURE' => 'www.squareup.com' },
          params: payload.to_json
        )
      end

      context 'with pool donation' do
        let(:seller_id) { seller_pool.seller_id }

        context 'with nice pool donation' do
          let(:amount) { 5000 }
          let(:item_type) { 'donation' }

          it 'creates pool donation' do
            expect(seller1.donation_amount).to eq(25_00)
            expect(seller2.donation_amount).to eq(35_00)
          end

          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end
        end

        context 'with non-divisible number round' do
          let(:amount) { 3 }
          let(:item_type) { 'donation' }

          it 'creates pool donation and distrubutes the cents' do
            expect(seller1.donation_amount).to eq(2)
            expect(seller2.donation_amount).to eq(10_01)
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
              expect(seller1.donation_amount).to eq(1_12)
              expect(seller3.donation_amount).to eq(1_12)
              expect(seller2.donation_amount).to eq(11_11)
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
    end

    describe 'gift cards' do
      def verify_gift_card(item:, single_use:, amount:)
        expect(item).not_to be_nil

        gift_card_detail = item.gift_card_detail
        expect(gift_card_detail).not_to be_nil
        expect(gift_card_detail.single_use).to eq(single_use)
        expect(gift_card_detail.expiration).to eq(Date.today + 1.year)
        expect(gift_card_detail.amount).to eq(amount)

        payment_intent = item.payment_intent
        expect(payment_intent.successful).to be true
        expect(payment_intent.recipient).not_to eq(payment_intent.purchaser)
        expect(item.purchaser).to eq(payment_intent.purchaser)
        expect(gift_card_detail.recipient).to eq(payment_intent.recipient)
      end

      let(:amount) { 5000 }
      let(:item_type) { 'gift_card' }
      let(:seller_id) { seller1.seller_id }

      context 'with is_distribution = true' do
        let(:is_distribution) { true }

        before do
          expect(EmailManager::DonationReceiptSender).to receive(:call).once
          post(
            '/webhooks',
            headers: { 'HTTP_X_SQUARE_SIGNATURE' => 'www.squareup.com' },
            params: payload.to_json
          )
        end

        it 'creates a single use gift card' do
          item = Item.where(
            seller_id: seller1.id,
            item_type: 'gift_card'
          ).first
          verify_gift_card(item: item, single_use: true, amount: amount)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'with is_distribution = false' do
        before do
          expect(EmailManager::GiftCardReceiptSender).to receive(:call)
          post(
            '/webhooks',
            headers: { 'HTTP_X_SQUARE_SIGNATURE' => 'www.squareup.com' },
            params: payload.to_json
          )
        end

        it 'creates a gift card' do
          item = Item.where(
            seller_id: seller1.id,
            item_type: 'gift_card'
          ).first
          verify_gift_card(item: item, single_use: false, amount: amount)
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

      context 'with multiple is_distribution gift cards' do
        let(:line_items) do
          [
            {
            'amount': amount1,
            'currency': 'usd',
            'item_type': item_type,
            'quantity': 1,
            'seller_id': seller_id,
            'is_distribution': true
            },
            {
              'amount': amount2,
              'currency': 'usd',
              'item_type': item_type,
              'quantity': 1,
              'seller_id': seller_id,
              'is_distribution': true
            }
          ].to_json
        end

        let(:amount1) { 1000 }
        let(:amount2) { 2000 }
        let(:item_type) { 'gift_card' }
        let(:seller_id) { seller1.seller_id }

        before do
          # Sends only one email, even though two gift cards were created
          expect(EmailManager::DonationReceiptSender).to receive(:call)
            .once
            .with({
              payment_intent: payment_intent,
              amount: amount1 + amount2,
              merchant: seller1.name,
              email: payment_intent.purchaser.email
            })
          post(
            '/webhooks',
            headers: { 'HTTP_X_SQUARE_SIGNATURE' => 'www.squareup.com' },
            params: payload.to_json
          )
        end

        it 'creates a single use gift card' do
          # verify_gift_card(single_use: true)
          items = Item.where(
            seller_id: seller1.id,
            item_type: 'gift_card'
          )
          expect(items.size).to eq 2
          verify_gift_card(item: items.first, single_use: true, amount: amount1)
          verify_gift_card(
            item: items.second,
            single_use: true,
            amount: amount2
          )
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
