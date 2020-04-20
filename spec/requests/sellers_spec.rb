
require 'rails_helper'

RSpec.describe 'Sellers API', type: :request do
  # initialize test data
  before { freeze_time }
  let(:current_time) { Time.current.utc.iso8601(3).to_s }
  let(:seller_id1) { seller1.seller_id }
  let!(:seller1) do
    Seller.create(
      seller_id: 'shunfa-bakery',
      cuisine_name: 'Chinese',
      name: 'Shunfa Bakery',
      story: 'I am but a small, small boy',
      owner_name: 'Ben Jerry',
      owner_image_url: 'https://www.aws.com/98nuw9e8unf9awnuefaiwenfoaijfosdf',
      accept_donations: true,
      sell_gift_cards: true,
      business_type: "small-biz",
      num_employees: 5,
      founded_year: 1850,
      website_url: 'https://www.youtube.com/watch?v=jIIuzB11dsA',
      menu_url: 'https://www.youtube.com/watch?v=jIIuzB11dsA',
    )
  end
  let!(:seller2) do
    Seller.create(
      seller_id: '87-lan-zhou-handpooled-noods',
      cuisine_name: 'Noodle Soup',
      name: '87 Lan Zhou Handpooled Noods',
      story: 'Been pullin noods since I was 2',
      owner_name: 'Tom Hanks',
      owner_image_url: 'https://www.aws.com/oawjeoiajwef9wuef09wuef09waeuf',
      accept_donations: false,
      sell_gift_cards: true,
      business_type: "medium-biz",
      num_employees: 10,
      founded_year: 1950,
      website_url: 'https://www.youtube.com/watch?v=C_oACPWGvM4',
      menu_url: 'https://www.youtube.com/watch?v=C_oACPWGvM4',
    )
  end

  let(:valid_attributes) do
    {
      seller_id: 'new-url',
      cuisine_name: 'New Age Cuisine',
      name: 'New Shunfa Bakery',
      story: "I'm on a new level I'm on a new level",
      summary: "Darold Durard Brown Ferguson Jr. (born October 20, 1988), known by his stage name ASAP Ferg (stylized A$AP Ferg), is an American rapper and songwriter from New York City's Harlem neighborhood.",
      owner_name: 'A$AP Ferg',
      owner_image_url: 'https://www.youtube.com/watch?v=Srns7NiO278',
      accept_donations: true,
      sell_gift_cards: true,
      hero_image_url: 'superman-url',
      progress_bar_color: '#1234',
      sell_gift_cards: true,
      business_type: "tiny-biz",
      num_employees: 2,
      founded_year: 2017,
      website_url: 'https://www.youtube.com/watch?v=CIjXUg1s5gc',
      menu_url: 'https://www.youtube.com/watch?v=CIjXUg1s5gc',
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
        # Ignore id field since it's auto-incremented
        actual_json = json.except('id')
        expected_json = valid_attributes.except('id')
        expected_json['created_at'] = current_time
        expected_json['updated_at'] = current_time
        expected_json['target_amount'] = 1_000_000
        expected_json['amount_raised'] = 0
        expected_json['locations'] = []
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
        expected_json['target_amount'] = 1_000_000
        expected_json['amount_raised'] = 0
        expected_json['locations'] = []
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
        expected_json['target_amount'] = 1_000_000
        expected_json['amount_raised'] = 0
        expected_json['locations'] = []
        expect(actual_json).to eq(expected_json.with_indifferent_access)
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
      # Ignore id field since it's auto-incremented
      actual_json = json.except('id')
      expected_json = valid_attributes.except('id')
      expected_json['created_at'] = current_time
      expected_json['updated_at'] = current_time
      expected_json['target_amount'] = 1_000_000
      expected_json['amount_raised'] = 0
      expected_json['locations'] = []
      expect(actual_json).to eq(expected_json.with_indifferent_access)
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
