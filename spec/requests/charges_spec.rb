# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Charges API', type: :request do
  # Test suite for POST /charges
  describe 'POST /charges' do
    let(:email) { 'mrkrabs@thekrustykrab.com' }
    let(:nonce) { nil }
    let(:is_square) { false }
    let(:name) { 'Squarepants, Spongebob' }
    let(:seller_id) { 'shunfa-bakery' }
    let(:params) do
      {
        email: email,
        is_square: is_square,
        nonce: nonce,
        line_items: line_items,
        seller_id: seller_id,
        name: name
      }
    end
    let!(:seller) do
      create(
        :seller,
        seller_id: seller_id,
        square_location_id: 'E4R1NCMHG7B2Y',
        name: 'Shunfa Bakery'
      )
    end

    context 'with a gift card' do
      let(:line_items) do
        [
          {
            amount: 50,
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns Stripe PaymentIntent' do
        expect(json['id']).not_to be_empty
        expect(json['amount']).to eq(50)
        expect(json['currency']).to eq('usd')
        expect(json['receipt_email']).to eq(email)

        expect(
          PaymentIntent.find_by(email: email, line_items: line_items.to_json)
        ).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'using Square' do
      # Test value taken from https://developer.squareup.com/docs/testing/test-values
      let(:nonce) { 'cnon:card-nonce-ok' }
      let(:is_square) { true }

      context 'with a gift card' do
        let(:line_items) do
          [
            {
              amount: 50,
              currency: 'usd',
              item_type: 'gift_card',
              quantity: 1,
              seller_id: seller_id
            }
          ]
        end

        describe 'with error codes' do
          context 'with bad CVV' do
            # Test value taken from https://developer.squareup.com/docs/testing/test-values
            let(:nonce) { 'cnon:card-nonce-rejected-cvv' }

            it 'returns status code 400' do
              expect(response).to have_http_status(400)
            end

            it 'returns a validation failure message' do
              expect(response.body).to match(/CVV_FAILURE/)
            end
          end

          context 'with bad postal code' do
            # Test value taken from https://developer.squareup.com/docs/testing/test-values
            let(:nonce) { 'cnon:card-nonce-rejected-postalcode' }

            it 'returns status code 400' do
              expect(response).to have_http_status(400)
            end

            it 'returns a validation failure message' do
              expect(response.body).to match(/ADDRESS_VERIFICATION_FAILURE/)
            end
          end

          context 'with bad expiration date' do
            # Test value taken from https://developer.squareup.com/docs/testing/test-values
            let(:nonce) { 'cnon:card-nonce-rejected-expiration' }

            it 'returns status code 400' do
              expect(response).to have_http_status(400)
            end

            it 'returns a validation failure message' do
              expect(response.body).to match(/INVALID_EXPIRATION/)
            end
          end

          context 'with card declined' do
            # Test value taken from https://developer.squareup.com/docs/testing/test-values
            let(:nonce) { 'cnon:card-nonce-declined' }

            it 'returns status code 400' do
              expect(response).to have_http_status(400)
            end

            it 'returns a validation failure message' do
              expect(response.body).to match(/GENERIC_DECLINE/)
            end
          end

          context 'with card nonce already used' do
            # Test value taken from https://developer.squareup.com/docs/testing/test-values
            let(:nonce) { 'cnon:card-nonce-rejected-cvv' }

            it 'returns status code 400' do
              expect(response).to have_http_status(400)
            end

            it 'returns a validation failure message' do
              expect(response.body).to match(/CVV_FAILURE/)
            end
          end
        end

        before { post '/charges', params: params, as: :json }

        it 'returns Square Payment' do
          payment = json['data']['payment']
          expect(payment['id']).not_to be_empty
          expect(payment['amount_money']['amount']).to eq(50)
          expect(payment['amount_money']['currency']).to eq('USD')
          expect(payment['buyer_email_address']).to eq(email)

          expect(
            PaymentIntent.find_by(email: email, line_items: line_items.to_json)
          ).not_to be_nil
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'with a gift card and donation' do
        let(:line_items) do
          [
            {
              amount: 5000,
              currency: 'usd',
              item_type: 'gift_card',
              quantity: 1,
              seller_id: seller_id
            },
            {
              amount: 3000,
              currency: 'usd',
              item_type: 'donation',
              quantity: 1,
              seller_id: seller_id
            }
          ]
        end

        before { post '/charges', params: params, as: :json }

        it 'returns Square Payment' do
          payment = json['data']['payment']
          expect(payment['id']).not_to be_empty
          expect(payment['amount_money']['amount']).to eq(8000)
          expect(payment['amount_money']['currency']).to eq('USD')
          expect(payment['buyer_email_address']).to eq(email)

          expect(
            PaymentIntent.find_by(email: email, line_items: line_items.to_json)
          ).not_to be_nil
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'with line item with missing amount' do
      let(:line_items) do
        [{ currency: 'usd', item_type: 'gift_card', quantity: 1 }]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(
          /param is missing or the value is empty: amount/
        )
      end
    end

    context 'with line item with missing currency' do
      let(:line_items) { [{ amount: 50, item_type: 'gift_card', quantity: 1 }] }

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(
          /param is missing or the value is empty: currency/
        )
      end
    end

    context 'with line item with missing item_type' do
      let(:line_items) do
        [{ amount: 50, currency: 'usd', quantity: 1, seller_id: seller_id }]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(
          /param is missing or the value is empty: item_type/
        )
      end
    end

    context 'with line item with missing quantity' do
      let(:line_items) do
        [
          {
            amount: 50,
            currency: 'usd',
            item_type: 'gift_card',
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(
          /param is missing or the value is empty: quantity/
        )
      end
    end

    context 'with charge with missing seller_id' do
      let(:line_items) do
        [{ amount: 50, currency: 'usd', item_type: 'gift_card', quantity: 1 }]
      end

      before do
        post '/charges',
             params: { email: 'Foobar@foo.com', line_items: line_items },
             as: :json
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(
          /param is missing or the value is empty: seller_id/
        )
      end
    end

    context 'with an invalid name' do
      let(:line_items) do
        [
          {
            amount: 5000,
            currency: 'usd',
            item_type: 'Foobar',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(
          /line_item must be named `gift_card` or `donation`/
        )
      end
    end

    context 'with a negative amount' do
      let(:line_items) do
        [
          {
            amount: -1,
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(
          '{"message":"Amount must be at least $0.50 usd"}'
        )
      end
    end

    context 'with $.49 in the amount' do
      let(:line_items) do
        [
          {
            amount: 49,
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(
          '{"message":"Amount must be at least $0.50 usd"}'
        )
      end
    end

    context 'with string integer amount' do
      let(:line_items) do
        [
          {
            amount: '50',
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match('line_item.amount must be an Integer')
      end
    end

    context 'with float amount' do
      let(:line_items) do
        [
          {
            amount: 50.5,
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match('line_item.amount must be an Integer')
      end
    end

    context 'with a gift card and donation' do
      let(:line_items) do
        [
          {
            amount: 5000,
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          },
          {
            amount: 3000,
            currency: 'usd',
            item_type: 'donation',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns Stripe PaymentIntent' do
        expect(json['id']).not_to be_empty
        expect(json['amount']).to eq(8000)
        expect(json['currency']).to eq('usd')
        expect(json['receipt_email']).to eq(email)

        expect(
          PaymentIntent.find_by(email: email, line_items: line_items.to_json)
        ).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is missing email' do
      before do
        post(
          '/charges',
          params: {
            seller_id: seller_id,
            line_items: [
              {
                amount: 50, currency: 'usd', item_type: 'gift_card', quantity: 1
              }
            ],
            name: 'Jane Doe'
          },
          as: :json
        )
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(
          /param is missing or the value is empty: email/
        )
      end
    end

    context 'when the request is missing line_items' do
      before { post '/charges', params: { email: 'Foobar@foo.com' }, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(
          /param is missing or the value is empty: seller_id/
        )
      end
    end

    describe 'PaymentIntent' do
      context 'includes gift cards' do
        let!(:seller2) { create(:seller, name: 'Uncle Boons') }

        let(:line_items) do
          [
            {
              amount: 5050,
              currency: 'usd',
              item_type: 'gift_card',
              quantity: 2,
              seller_id: seller.seller_id
            },
            {
              amount: 3000,
              currency: 'usd',
              item_type: 'donation',
              quantity: 1,
              seller_id: seller2.seller_id
            }
          ]
        end

        it 'should include gift card details' do
          thank_you = "Thank you for supporting #{seller.name}."
          expect(Stripe::PaymentIntent).to receive(:create).with(
            amount: 13_100,
            currency: 'usd',
            payment_method_types: %w[card],
            receipt_email: email,
            description:
              thank_you +
                ' Your gift card(s) will be emailed to you when the seller opens back up.'
          ).and_call_original

          post '/charges', params: params, as: :json
        end
      end

      context 'when donations only' do
        let(:line_items) do
          [
            {
              amount: 5050, currency: 'usd', item_type: 'donation', quantity: 2
            },
            {
              amount: 3000, currency: 'usd', item_type: 'donation', quantity: 1
            },
            {
              amount: 3000, currency: 'usd', item_type: 'donation', quantity: 1
            }
          ]
        end

        before { post '/charges', params: params, as: :json }
        it 'should not include gift card details' do
          thank_you = "Thank you for supporting #{seller.name}."
          expect(Stripe::PaymentIntent).to receive(:create).with(
            amount: 16_100,
            currency: 'usd',
            receipt_email: email,
            payment_method_types: %w[card],
            description: thank_you
          ).and_call_original

          post '/charges', params: params, as: :json
        end
      end
    end
  end
end
