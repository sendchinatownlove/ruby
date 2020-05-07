require 'rails_helper'

RSpec.describe "RecentContributions", type: :request do

  before(:all) do
    @seller = create :seller
    @donation_item = create(:item, :donation_item, seller_id: @seller.id)
    @donation_detail = create(:donation_detail, item_id: @donation_item.id)
  end

  it 'should return most recent donation' do
    get "/sellers/#{@seller.seller_id}/recent_contribution"

    expect(response).to have_http_status(200)
    expect(response.body).to eq(@donation_detail.to_json)
  end

  it 'should return most gift card' do
    gift_card_item = create(:item, :gift_card_item, seller_id: @seller.id)
    gift_card_detail = create(:gift_card_detail, item_id: gift_card_item.id)

    get "/sellers/#{@seller.seller_id}/recent_contribution"

    expect(response).to have_http_status(200)
    expect(response.body).to eq(gift_card_detail.to_json)
  end

end
