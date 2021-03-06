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

  context 'GET /gift_cards' do
    context 'with no session' do
      before { get '/gift_cards' }

      it 'returns a 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'with an invalid contact' do
      before do
        allow_any_instance_of(GiftCardsController).to receive(:get_session_user)
          .and_return({
                        email: 'test@foo.com'
                      })
        get '/gift_cards'
      end

      it 'returns a 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'with a valid contact' do
      let!(:contact) { create(:contact) }
      let!(:seller) { create(:seller) }
      let!(:location) { create(:location, seller_id: seller.id)}
      let!(:distributor) { create(:distributor, contact_id: contact.id) }
      let!(:campaign) { create(:campaign, distributor_id: distributor.id, seller_id: seller.id) }
      let!(:item_0) { create(:item,
        campaign_id: campaign.id,
        seller_id: seller.id,
        purchaser_id: contact.id) }
      let!(:item_1) { create(:item,
        campaign_id: campaign.id,
        seller_id: seller.id,
        purchaser_id: contact.id) }

      let!(:gift_card_detail_0) do
        create(
          :gift_card_detail,
          item_id: item_0.id
        )
      end
      let!(:gift_card_detail_1) do
        create(
          :gift_card_detail,
          item_id: item_1.id
        )
      end
      let(:gift_card_amount12) { create(:gift_card_amount, gift_card_detail_id: gift_card_detail_0.id) }
      let(:gift_card_amount13) { create(:gift_card_amount, gift_card_detail_id: gift_card_detail_1.id) }

      before do
        allow_any_instance_of(GiftCardsController).to receive(:get_session_user).and_return(contact)
        get '/gift_cards'
      end

      it 'returns a 200' do
        # get '/gift_cards'
        expect(response).to have_http_status(200)
      end

      it 'returns the gift card details' do
        # get '/gift_cards'

        puts json.inspect
        expect(json).not_to be_empty
        expect(json[:gift_cards].size).to eq 2

        expect(response.headers['Current-Page'].to_i).to eq 1
        expect(response.headers['Total-Pages'].to_i).to eq 1
        expect(response.headers['Total-Count'].to_i).to eq 2
      end
    end
  end

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
