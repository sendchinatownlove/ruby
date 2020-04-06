
require 'rails_helper'

RSpec.describe 'Sellers API', type: :request do
  # initialize test data
  before { freeze_time }
  let(:current_time) { Time.current.utc.iso8601(3).to_s }
  let(:url1) { seller1.url }
  let!(:seller1) do
    Seller.create(
      url: 'shunfa-bakery',
      cuisine_name: 'Chinese',
      merchant_name: 'Shunfa Bakery',
      story: 'I am but a small, small boy',
      owner_name: 'Ben Jerry',
      owner_image_url: 'https://www.aws.com/98nuw9e8unf9awnuefaiwenfoaijfosdf',
      accept_donations: true,
      sell_gift_cards: true
    )
  end
  let!(:seller2) do
    Seller.create(
      url: '87-lan-zhou-handpooled-noods',
      cuisine_name: 'Noodle Soup',
      merchant_name: '87 Lan Zhou Handpooled Noods',
      story: 'Been pullin noods since I was 2',
      owner_name: 'Tom Hanks',
      owner_image_url: 'https://www.aws.com/oawjeoiajwef9wuef09wuef09waeuf',
      accept_donations: false,
      sell_gift_cards: true
    )
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

  # Test suite for GET /sellers/:url
  describe 'GET /sellers/:url' do
    before { get "/sellers/#{url1}" }

    context 'when the record exists' do
      it 'returns the seller' do
        expect(json).not_to be_empty
        expect(json['url']).to eq(url1)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:url1) { 'shunfa-baker' }

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
    # valid payload
    let(:valid_attributes) do
      {
        url: 'the-pickle-guys',
        cuisine_name: 'Pickles',
        merchant_name: 'The Pickle Guys',
        story: 'i eat pickles everyday for every meal — i LOOOOOVE pickles',
        owner_name: 'Pickle Rick',
        owner_image_url: 'https://www.youtube.com/watch?v=tZp8sY06Qoc',
        accept_donations: true,
        sell_gift_cards: true
      }
    end

    context 'when the request is valid' do
      before { post '/sellers', params: valid_attributes, as: :json }

      it 'creates a seller' do
        # Ignore id field since it's auto-incremented
        actual_json = json.except('id')
        expected_json = valid_attributes.except('id')
        expected_json['created_at'] = current_time
        expected_json['updated_at'] = current_time
        expect(actual_json).to eq(expected_json.with_indifferent_access)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'without accept_donation' do
      before { post '/sellers', params: valid_attributes.except(:accept_donations), as: :json }

      it 'creates a seller with default accept_donations' do
        # Ignore id field since it's auto-incremented
        actual_json = json.except('id')
        expected_json = valid_attributes.except('id')
        expected_json['created_at'] = current_time
        expected_json['updated_at'] = current_time
        expected_json['accept_donations'] = true
        expect(actual_json).to eq(expected_json.with_indifferent_access)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'without accept_donation' do
      before { post '/sellers', params: valid_attributes.except(:sell_gift_cards), as: :json }

      it 'creates a seller with default accept_donations' do
        # Ignore id field since it's auto-incremented
        actual_json = json.except('id')
        expected_json = valid_attributes.except('id')
        expected_json['created_at'] = current_time
        expected_json['updated_at'] = current_time
        expected_json['sell_gift_cards'] = false
        expect(actual_json).to eq(expected_json.with_indifferent_access)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'with no url' do
      before do
        post '/sellers', params: valid_attributes.except(:url), as: :json
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: url/)
      end
    end
  end

  # Test suite for PUT /sellers/:url
  describe 'PUT /sellers/:url' do
    let(:valid_attributes) do
      {
        url: 'new-url',
        cuisine_name: 'New Age Cuisine',
        merchant_name: 'New Shunfa Bakery',
        story: "I'm on a new level I'm on a new level",
        owner_name: 'A$AP Ferg',
        owner_image_url: 'https://www.youtube.com/watch?v=Srns7NiO278',
        accept_donations: true,
        sell_gift_cards: true
      }
    end

    context 'when the record exists' do
      before { put "/sellers/#{url1}", params: valid_attributes, as: :json }

      it 'updates the record' do
        # Ignore id field since it's auto-incremented
        actual_json = json.except('id')
        expected_json = valid_attributes.except('id')
        expected_json['created_at'] = current_time
        expected_json['updated_at'] = current_time
        expect(actual_json).to eq(expected_json.with_indifferent_access)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      context 'when the record does not exist' do
        let(:url1) { 'shunfa-baker' }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Seller/)
        end
      end
    end
  end
end
