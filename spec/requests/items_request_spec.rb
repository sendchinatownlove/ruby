# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Items', type: :request do
  before do
    @seller = create :seller
    @first_item = create(:item, :donation_item, seller_id: @seller.id)
    @second_item = create(:item, :gift_card_item, seller_id: @seller.id)
  end

  it 'should validate invalid order' do
    get "/sellers/#{@seller.seller_id}/items", params: { order: 'foo' }

    expect(response).to have_http_status(422)
  end

  it 'should validate invalid limit' do
    get "/sellers/#{@seller.seller_id}/items", params: { limit: 5.5 }

    expect(response).to have_http_status(422)
  end

  it 'should validate invalid limit and valid order' do
    get "/sellers/#{@seller.seller_id}/items", params: { order: 'foo', limit: 5 }

    expect(response).to have_http_status(422)
  end

  it 'should validate invalid limit and valid order' do
    get "/sellers/#{@seller.seller_id}/items", params: { order: 'foo', limit: 5 }

    expect(response).to have_http_status(422)
  end

  it 'should return most gift card contribution' do
    get "/sellers/#{@seller.seller_id}/items", params: { order: 'desc', limit: 1 }

    expect(response).to have_http_status(200)
    expect(JSON.parse(response.body)['items'].length).to eq(1)
    expect(JSON.parse(response.body)['items'][0].to_json).to eq(@second_item.to_json)
  end

  it 'should return last donation contribution' do
    get "/sellers/#{@seller.seller_id}/items", params: { order: 'asc', limit: 1 }

    expect(response).to have_http_status(200)
    expect(JSON.parse(response.body)['items'].length).to eq(1)
    expect(JSON.parse(response.body)['items'][0].to_json).to eq(@first_item.to_json)
  end

  it 'should return both contributions descending' do
    get "/sellers/#{@seller.seller_id}/items", params: { order: 'desc', limit: 2 }

    expect(response).to have_http_status(200)
    expect(JSON.parse(response.body)['items'].length).to eq(2)
    expect(JSON.parse(response.body)['items'][0].to_json).to eq(@second_item.to_json)
    expect(JSON.parse(response.body)['items'][1].to_json).to eq(@first_item.to_json)
  end

  it 'should return both contributions ascending' do
    get "/sellers/#{@seller.seller_id}/items", params: { order: 'asc', limit: 2 }

    expect(response).to have_http_status(200)
    expect(JSON.parse(response.body)['items'][0].to_json).to eq(@first_item.to_json)
    expect(JSON.parse(response.body)['items'][1].to_json).to eq(@second_item.to_json)
  end

  it 'should return default query limit to 10 and order to desc' do
    get "/sellers/#{@seller.seller_id}/items"

    expect(response).to have_http_status(200)
    expect(JSON.parse(response.body)['items'][0].to_json).to eq(@second_item.to_json)
    expect(JSON.parse(response.body)['items'][1].to_json).to eq(@first_item.to_json)
  end
end
