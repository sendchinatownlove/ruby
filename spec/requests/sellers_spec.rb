# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sellers API', type: :request do
  # initialize test data
  let(:seller_id1) { seller1.seller_id }
  let!(:seller1) do
    create(:seller)
  end
  let!(:seller2) do
    create(:seller)
  end

  let(:valid_attributes) do
    {
      seller_id: 'new-url',
      cuisine_name: 'New Age Cuisine',
      name: 'New Shunfa Bakery',
      story: "I'm on a new level I'm on a new level",
      summary: "Darold Durard Brown Ferguson Jr. (born October 20, 1988), known
        by his stage name ASAP Ferg (stylized A$AP Ferg), is an American rapper
        and songwriter from New York City's Harlem neighborhood.",
      owner_name: 'A$AP Ferg',
      owner_image_url: 'https://www.youtube.com/watch?v=Srns7NiO278',
      accept_donations: false,
      sell_gift_cards: true,
      hero_image_url: 'superman-url',
      progress_bar_color: '#1234',
      business_type: 'tiny-biz',
      num_employees: 2,
      founded_year: 2017,
      website_url: 'https://www.youtube.com/watch?v=CIjXUg1s5gc',
      menu_url: 'https://www.youtube.com/watch?v=CIjXUg1s5gc',
      square_location_id: 'new_square_location_id'
    }
  end

  # Test suite for GET /sellers
  describe 'GET /sellers' do
    # make HTTP get request before each example
    before { get '/sellers' }

    it 'returns sellers' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(2)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /sellers
  describe 'GET /sellers sort by created_at asc' do
    # make HTTP get request before each example
    before { get '/sellers?sort=created_at:asc' }

    it 'returns sellers' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(2)
      expect(json[0]['id']).to eq(seller1.id)
      expect(json[1]['id']).to eq(seller2.id)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /sellers
  describe 'GET /sellers sort by created_at desc' do
    # make HTTP get request before each example
    before { get '/sellers?sort=created_at:desc' }

    it 'returns sellers' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(2)
      expect(json[0]['id']).to eq(seller2.id)
      expect(json[1]['id']).to eq(seller1.id)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /sellers/:seller_id
  describe 'GET /sellers/seller_id' do
    before { get "/sellers/#{seller_id1}" }

    context 'when the record exists' do
      it 'returns the seller' do
        expect(json).not_to be_empty
        expect(json['seller_id']).to eq(seller_id1)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:seller_id1) { 'shunfa-baker' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Seller/)
      end
    end
  end

  # Test suite for POST /sellers
  describe 'POST /sellers' do
    context 'when the request is valid' do
      before { post '/sellers', params: valid_attributes, as: :json }

      it 'creates a seller' do
        new_seller = Seller.find_by(seller_id: valid_attributes[:seller_id])
        expect(new_seller).not_to be_nil
        expect(new_seller[:cuisine_name]).to eq(valid_attributes[:cuisine_name])
        expect(new_seller[:name]).to eq(valid_attributes[:name])
        expect(new_seller[:story]).to eq(valid_attributes[:story])
        expect(new_seller[:owner_name]).to eq(valid_attributes[:owner_name])
        expect(new_seller[:owner_image_url]).to eq(valid_attributes[:owner_image_url])
        expect(new_seller[:accept_donations]).to eq(valid_attributes[:accept_donations])
        expect(new_seller[:sell_gift_cards]).to eq(valid_attributes[:sell_gift_cards])
        expect(new_seller[:hero_image_url]).to eq(valid_attributes[:hero_image_url])
        expect(new_seller[:progress_bar_color]).to eq(valid_attributes[:progress_bar_color])
        expect(new_seller[:business_type]).to eq(valid_attributes[:business_type])
        expect(new_seller[:num_employees]).to eq(valid_attributes[:num_employees])
        expect(new_seller[:founded_year]).to eq(valid_attributes[:founded_year])
        expect(new_seller[:website_url]).to eq(valid_attributes[:website_url])
        expect(new_seller[:menu_url]).to eq(valid_attributes[:menu_url])
        expect(new_seller[:square_location_id]).to eq(valid_attributes[:square_location_id])
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'without accept_donation' do
      before do
        post(
          '/sellers',
          params: valid_attributes.except(:accept_donations),
          as: :json
        )
      end

      it 'creates a seller with default accept_donations' do
        new_seller = Seller.find_by(seller_id: valid_attributes[:seller_id])
        expect(new_seller).not_to be_nil
        expect(new_seller[:accept_donations]).to eq(true)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'without accept_donation' do
      before do
        post(
          '/sellers',
          params: valid_attributes.except(:sell_gift_cards),
          as: :json
        )
      end

      it 'creates a seller with default sell_gift_cards' do
        new_seller = Seller.find_by(seller_id: valid_attributes[:seller_id])
        expect(new_seller).not_to be_nil
        expect(new_seller[:sell_gift_cards]).to eq(false)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'with no url' do
      before do
        post '/sellers', params: valid_attributes.except(:seller_id), as: :json
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: seller_id/)
      end
    end
  end

  # Test suite for PUT /sellers/seller_id
  describe 'PUT /sellers/seller_id' do
    before { put "/sellers/#{seller_id1}", params: valid_attributes, as: :json }

    it 'updates the record' do
      new_seller = Seller.find_by(seller_id: valid_attributes[:seller_id])
      expect(new_seller).not_to be_nil
      expect(new_seller[:cuisine_name]).to eq(valid_attributes[:cuisine_name])
      expect(new_seller[:name]).to eq(valid_attributes[:name])
      expect(new_seller[:story]).to eq(valid_attributes[:story])
      expect(new_seller[:owner_name]).to eq(valid_attributes[:owner_name])
      expect(new_seller[:owner_image_url]).to eq(valid_attributes[:owner_image_url])
      expect(new_seller[:accept_donations]).to eq(valid_attributes[:accept_donations])
      expect(new_seller[:sell_gift_cards]).to eq(valid_attributes[:sell_gift_cards])
      expect(new_seller[:hero_image_url]).to eq(valid_attributes[:hero_image_url])
      expect(new_seller[:progress_bar_color]).to eq(valid_attributes[:progress_bar_color])
      expect(new_seller[:business_type]).to eq(valid_attributes[:business_type])
      expect(new_seller[:num_employees]).to eq(valid_attributes[:num_employees])
      expect(new_seller[:founded_year]).to eq(valid_attributes[:founded_year])
      expect(new_seller[:website_url]).to eq(valid_attributes[:website_url])
      expect(new_seller[:menu_url]).to eq(valid_attributes[:menu_url])
      expect(new_seller[:square_location_id]).to eq(valid_attributes[:square_location_id])
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end

    context 'when the record does not exist' do
      let(:seller_id1) { 'shunfa-baker' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Seller/)
      end
    end
  end
end
