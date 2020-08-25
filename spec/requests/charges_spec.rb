# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Charges API', type: :request do
  # Test suite for POST /charges
  describe 'POST /charges' do
    let(:email) { 'mrkrabs@thekrustykrab.com' }
    let(:nonce) { 'cnon:card-nonce-ok' }
    let(:is_square) { true }
    let(:name) { 'Squarepants, Spongebob' }
    let(:seller_id) { 'shunfa-bakery' }
    let(:idempotency_key) { '123' }
    let(:is_subscribed) { 'true' }
    let(:is_distribution) { false }
    let(:params) do
      {
        email: email,
        is_square: is_square,
        nonce: nonce,
        line_items: line_items,
        seller_id: seller_id,
        name: name,
        idempotency_key: idempotency_key,
        is_subscribed: is_subscribed,
        is_distribution: is_distribution
      }
    end
    let!(:seller) do
      create(:seller,
             :with_campaign,
             seller_id: seller_id,
             square_location_id: ENV['SQUARE_LOCATION_ID'],
             name: 'Shunfa Bakery',
             cost_per_meal: 100)
    end

    let(:expected_line_items) do
      line_items.map { |li| li.except(:is_distribution) }
    end

    context 'using Square' do
      # Test value taken from https://developer.squareup.com/docs/testing/test-values
      let(:nonce) { 'cnon:card-nonce-ok' }

      context 'with a gift card' do
        let(:line_items) do
          [
            {
              amount: 50,
              currency: 'usd',
              item_type: 'gift_card',
              quantity: 1,
              seller_id: seller_id,
              is_distribution: is_distribution
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

          contact = Contact.find_by(email: email, name: name)

          expect(contact).not_to be_nil
          expect(
            PaymentIntent.find_by(recipient: contact, line_items: expected_line_items.to_json)
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
              seller_id: seller_id,
              is_distribution: is_distribution
            },
            {
              amount: 3000,
              currency: 'usd',
              item_type: 'donation',
              quantity: 1,
              seller_id: seller_id,
              is_distribution: is_distribution
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

          contact = Contact.find_by(email: email, name: name)

          expect(contact).not_to be_nil
          expect(
            PaymentIntent.find_by(recipient: contact, line_items: expected_line_items.to_json)
          ).not_to be_nil
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'with gift card donation for distribution' do
        let(:line_items) do
          [
            {
              amount: 3000,
              currency: 'usd',
              item_type: 'donation',
              quantity: 1,
              seller_id: seller_id,
              is_distribution: is_distribution
            }
          ]
        end

        let(:is_distribution) { true }

        before { post '/charges', params: params, as: :json }

        it 'returns Square Payment' do
          payment = json['data']['payment']
          expect(payment['id']).not_to be_empty
          expect(payment['amount_money']['amount']).to eq(3000)
          expect(payment['amount_money']['currency']).to eq('USD')
          expect(payment['buyer_email_address']).to eq(email)

          contact = Contact.find_by(email: email, name: name)
          payment_intent = PaymentIntent.find_by(
            purchaser: contact,
            line_items: expected_line_items.to_json
          )

          expect(contact).not_to be_nil
          expect(payment_intent).not_to be_nil
          expect(payment_intent.recipient).not_to eq(contact)
          expect(payment_intent.recipient).to eq(seller.campaigns.first.distributor.contact)
          expect(payment_intent.recipient).not_to eq(payment_intent.purchaser)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'with a duplicate payment request' do
      let(:line_items) do
        [{ currency: 'usd', item_type: 'gift_card', quantity: 1 }]
      end

      before do
        post '/charges', params: params, as: :json
        allow_any_instance_of(ExistingEvent).to receive(:save).and_return(false)
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
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

    context 'with an amount that does not divide the seller cost per meal' do
      let(:is_distribution) { true }
      let(:line_items) do
        [
          {
            amount: 120,
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
          /^.*Gift A Meal amount '\d+' must be divisible by seller's cost per meal '\d+'..*$/
        )
      end
    end
  end
end
