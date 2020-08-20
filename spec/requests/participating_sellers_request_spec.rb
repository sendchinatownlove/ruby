require 'rails_helper'

RSpec.describe "ParticipatingSellers", type: :request do

  describe 'GET /participating_sellers' do
    let!(:participating_seller1) { create :participating_seller }
    let!(:participating_seller2) { create :participating_seller }
    before { get '/participating_sellers' }

    it 'returns the sellers' do
      expect(json).not_to be_empty
      expect(json.size).to eq(2)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /participating_sellers/:id' do
    let!(:participating_seller) { create :participating_seller }
    before { get "/participating_sellers/#{participating_seller_id}" }

    context 'with valid participating_seller_id' do
      let(:participating_seller_id) { participating_seller.id }

      it 'returns the participating_seller' do
        expect(json['id']).to eq participating_seller.id
        expect(json['seller_id']).to eq participating_seller.seller_id
        expect(json['stamp_url']).to eq participating_seller.stamp_url
        expect(json['name']).to eq participating_seller.name
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid participating_seller_id' do
      let(:participating_seller_id) { 'notarealid' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find ParticipatingSeller/)
      end
    end
  end

  describe 'POST /participating_sellers' do
    let!(:seller) { create :seller }
    before do
      post(
        '/participating_sellers',
        params: attrs,
        as: :json
      )
    end

    context 'with valid attrs' do
      let(:attrs) do
        {
          seller_id: seller.id,
          name: '46 Mott',
          stamp_url: 'sendchinatownlove.com/test_stamp_url',
        }
      end

      it 'creates the participating seller' do
        participating_seller = ParticipatingSeller.find(json['id'])

        expect(json['id']).to eq participating_seller.id
        expect(json['name']).to eq participating_seller.name
        expect(json['stamp_url']).to eq participating_seller.stamp_url

        expect(participating_seller).not_to be_nil
        expect(participating_seller.name).to eq attrs[:name]
        expect(participating_seller.stamp_url).to eq attrs[:stamp_url]
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'with extra attrs' do
      let(:attrs) do
        {
          seller_id: seller.id,
          name: '46 Mott',
          stamp_url: 'sendchinatownlove.com/test_stamp_url',
          extra: 'extra read all about it'
        }
      end

      it 'creates the participating seller' do
        participating_seller = ParticipatingSeller.find(json['id'])

        expect(json['id']).to eq participating_seller.id
        expect(json['name']).to eq participating_seller.name
        expect(json['stamp_url']).to eq participating_seller.stamp_url

        expect(participating_seller).not_to be_nil
        expect(participating_seller.name).to eq attrs[:name]
        expect(participating_seller.stamp_url).to eq attrs[:stamp_url]
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end
  end

  describe 'PUT /participating_sellers/:id' do
    let!(:participating_seller) { create :participating_seller }
    let!(:seller) { create :seller }
    before do
      put(
        "/participating_sellers/#{participating_seller_id}",
        params: attrs,
        as: :json
      )
    end

    context 'with valid attrs' do
      let(:participating_seller_id) { participating_seller.id }
      let(:attrs) do
        {
          seller_id: seller.id,
          name: '46 Mott',
          stamp_url: 'sendchinatownlove.com/test_stamp_url',
        }
      end

      it 'updates the participating_seller' do
        participating_seller = ParticipatingSeller.find(json['id'])
        expect(participating_seller).not_to be_nil
        expect(participating_seller.name).to eq attrs[:name]
        expect(participating_seller.stamp_url).to eq attrs[:stamp_url]
      end

      it 'returns the updated distributor' do
        participating_seller = ParticipatingSeller.find(json['id'])
        expect(json['id']).to eq participating_seller.id
        expect(json['name']).to eq participating_seller.name
        expect(json['stamp_url']).to eq participating_seller.stamp_url
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

end
