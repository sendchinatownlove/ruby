require 'rails_helper'

RSpec.describe 'Charges API', type: :request do
  # Test suite for POST /charges
  describe 'POST /charges' do
    let(:params) { { merchant_id: merchant_id, line_items: line_items } }
    let(:merchant_id) { 'shunfa-bakery' }

    context 'with a gift card' do
      let(:line_items) do
        [{ amount: 50,
           currency: 'usd',
           name: 'Gift Card',
           quantity: 1,
           description: '$0.50 gift card for Shunfa Bakery'
        }]
      end

      before { post '/charges', params: params }

      it 'returns stripe charges checkout session' do
        expect(json['id']).not_to be_empty
        expect(json['display_items']).to eq([{
          amount: 50,
          currency: 'usd',
          custom: {
            description: '$0.50 gift card for Shunfa Bakery',
            images: nil,
            name: 'Gift Card'
          },
          quantity: 1,
          type: 'custom'
        }.with_indifferent_access])
        expect(json['success_url']).to eq('https://sendchinatownlove.com/shunfa-bakery/thank-you?session_id={CHECKOUT_SESSION_ID}')
        expect(json['cancel_url']).to eq('https://sendchinatownlove.com/shunfa-bakery/canceled')
        expect(json['metadata']).to eq({ merchant_id: 'shunfa-bakery' }.with_indifferent_access)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'with line item with missing amount' do
      let(:line_items) do
        [{
          currency: 'usd',
          name: 'Gift Card',
          quantity: 1,
          description: '$50.00 gift card for Shunfa Bakery'
        }]
      end

      before { post '/charges', params: params }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: amount/)
      end
    end

    context 'with line item with missing currency' do
      let(:line_items) do
        [{
          amount: 5000,
          name: 'Gift Card',
          quantity: 1,
          description: '$50.00 gift card for Shunfa Bakery'
        }]
      end

      before { post '/charges', params: params }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: currency/)
      end
    end

    context 'with line item with missing name' do
      let(:line_items) do
        [{
          amount: 5000,
          currency: 'usd',
          quantity: 1,
          description: '$50.00 gift card for Shunfa Bakery'
        }]
      end

      before { post '/charges', params: params }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: name/)
      end
    end

    context 'with line item with missing quantity' do
      let(:line_items) do
        [{
          amount: 5000,
          currency: 'usd',
          name: 'Gift Card',
          description: '$50.00 gift card for Shunfa Bakery'
        }]
      end

      before { post '/charges', params: params }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: quantity/)
      end
    end

    context 'with an invalid name' do
      let(:line_items) do
        [{ amount: 5000,
           currency: 'usd',
           name: 'Foobar',
           quantity: 1,
           description: '$50.00 gift card for Shunfa Bakery'
        }]
      end

      before { post '/charges', params: params }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/line_item must be named `Gift Card` or `Donation`/)
      end
    end

    context 'with a negative amount' do
      let(:line_items) do
        [{ amount: -1,
           currency: 'usd',
           name: 'Gift Card',
           quantity: 1,
           description: '$50.00 gift card for Shunfa Bakery'
        }]
      end

      before { post '/charges', params: params }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("Amount must be at least $0.50 usd")
      end
    end

    context 'with $.49 in the amount' do
      let(:line_items) do
        [{ amount: 49,
           currency: 'usd',
           name: 'Gift Card',
           quantity: 1,
           description: '$00.49 gift card for Shunfa Bakery'
        }]
      end

      before { post '/charges', params: params }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("Amount must be at least $0.50 usd")
      end
    end

    context 'with a gift card and donation' do
      let(:line_items) do
        [{
          amount: 5000,
          currency: 'usd',
          name: 'Gift Card',
          quantity: 1,
          description: '$50.00 gift card for Shunfa Bakery'
       },
       { amount: 3000,
         currency: 'usd',
         name: 'Donation',
         quantity: 1,
         description: '$30.00 donation to Shunfa Bakery'
        }]
      end

      before { post '/charges', params: params }

      it 'returns stripe charges checkout session' do
        expect(json['id']).not_to be_empty
        expect(json['display_items']).to eq([
          {
            amount: 5000,
            currency: 'usd',
            custom: {
              description: '$50.00 gift card for Shunfa Bakery',
              images: nil,
              name: 'Gift Card'
            },
            quantity: 1,
            type: 'custom'
          }.with_indifferent_access,
          {
            amount: 3000,
            currency: 'usd',
            custom: {
              description: '$30.00 donation to Shunfa Bakery',
              images: nil,
              name: 'Donation'
            },
            quantity: 1,
            type: 'custom'
          }.with_indifferent_access
        ])
        expect(json['success_url']).to eq('https://sendchinatownlove.com/shunfa-bakery/thank-you?session_id={CHECKOUT_SESSION_ID}')
        expect(json['cancel_url']).to eq('https://sendchinatownlove.com/shunfa-bakery/canceled')
        expect(json['metadata']).to eq({ merchant_id: 'shunfa-bakery' }.with_indifferent_access)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is missing merchant_id' do
      before { post '/charges', params: { title: 'Foobar', line_items: [] } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: merchant_id/)
      end
    end

    context 'when the request is missing line_items' do
      before { post '/charges', params: { merchant_id: 'Foobar' } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: line_items/)
      end
    end
  end
end
