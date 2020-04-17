require 'rails_helper'

RSpec.describe 'MenuItems API' do
  # Initialize the test data
  let!(:seller) { create(:seller) }
  let!(:menu_items) { create_list(:menu_item, 20, seller_id: seller.id) }
  let(:seller_id) { seller.seller_id }
  let(:id) { menu_items.first.id }

  # Test suite for GET /sellers/:seller_id/menu_items
  describe 'GET /sellers/:seller_id/menu_items' do
    before { get "/sellers/#{seller_id}/menu_items" }

    context 'when seller exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all seller menu_items' do
        expect(json.size).to eq(20)
      end
    end

    context 'when seller does not exist' do
      let(:seller_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Seller/)
      end
    end
  end

  # Test suite for POST /sellers/:seller_id/menu_items
  describe 'POST /sellers/:seller_id/menu_items' do
    let(:valid_attributes) do
      {
        name: 'Food',
        description: 'Awesome Food',
        amount: 15,
        image_url: 'image.com'
      }
    end

    context 'when request attributes are valid' do
      before { post "/sellers/#{seller_id}/menu_items", params: valid_attributes, as: :json }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end
  end

  # Test suite for PUT /sellers/:seller_id/menu_items/:id
  describe 'PUT /sellers/:seller_id/menu_items/:id' do
    let(:valid_attributes) { { name: 'AwesomeFood' } }

    before { put "/sellers/#{seller_id}/menu_items/#{id}", params: valid_attributes, as: :json }

    context 'when menu_item exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'updates the menu_item' do
        updated_menu_item = MenuItem.find(id)
        expect(updated_menu_item.name).to match(/AwesomeFood/)
      end
    end

    context 'when the menu_item does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find MenuItem/)
      end
    end
  end
end
