require 'rails_helper'

RSpec.describe "Nonprofits", type: :request do

  describe 'GET /nonprofits/:id' do
    let!(:nonprofit) { create :nonprofit }
    before { get "/nonprofits/#{nonprofit_id}" }

    context 'with valid nonprofit_id' do
      let(:nonprofit_id) { nonprofit.id }

      it 'returns the nonprofit' do
        expect(json['id']).to eq nonprofit.id
        expect(json['name']).to eq nonprofit.name
        expect(json['logo_image_url']).to eq nonprofit.logo_image_url
        expect(json['contact_id']).to eq nonprofit.contact_id
        expect(json['fee_id']).to eq nonprofit.fee_id
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid nonprofit_id' do
      let(:nonprofit_id) { 'rrarararararararr' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Nonprofit/)
      end
    end
  end

end
