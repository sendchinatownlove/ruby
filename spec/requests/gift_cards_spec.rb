# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Gift Cards API', type: :request do
  let!(:gift_card_detail) do
    create(
      :gift_card_detail
    )
  end

  let!(:gift_card_amount1) do
    create(
      :gift_card_amount,
      gift_card_detail_id: gift_card_detail.id,
      created_at: Time.now - 2.days,
      value: 5000
    )
  end

  let!(:gift_card_amount2) do
    create(
      :gift_card_amount,
      gift_card_detail_id: gift_card_detail.id,
      created_at: Time.now - 1.day,
      value: 4000
    )
  end

  let!(:gift_card_id) { gift_card_detail.gift_card_id }

  context 'GET /gift_cards/:id' do
    before { get "/gift_cards/#{gift_card_id}" }

    context 'when gift card exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the gift card' do
        expect(json['id']).to eq(gift_card_detail.item_id)
        expect(json['gift_card_detail']['id']).to eq(gift_card_detail.id)
        expect(json['gift_card_detail']['amount'])
          .to eq(gift_card_amount2.value)
      end
    end

    context 'when gift card does not exist' do
      let(:gift_card_id) do
        '398r2ujdqwd'
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find GiftCard/)
      end
    end
  end

  context 'PUT /gift_cards/:id' do
    before do
      put "/gift_cards/#{gift_card_id}",
          params: { amount: amount },
          as: :json
    end

    let(:amount) { 3000 }

    context 'when gift card exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the gift card' do
        expect(json['gift_card_detail']['amount']).to eq(amount)
        expect(gift_card_detail.amount).to eq amount
      end
    end

    context 'when amount is greater' do
      let(:amount) { 5000 }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a not found message' do
        expect(response.body).to match(
          /New amount must be less than current amount of: #{gift_card_amount2.value}/
        )
      end
    end

    context 'when gift card does not exist' do
      let(:gift_card_id) { 'invalid_id' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find GiftCardDetail/)
      end
    end
  end
end
