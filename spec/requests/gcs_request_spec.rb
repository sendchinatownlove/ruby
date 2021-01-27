# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GCS', type: :request do
  let(:sample_request) do
    {
      file_name: 'dudebro-gmail-com-shunfa-bakery-2021-01-18T21-34-41-603Z.jpeg',
      file_type: 'image/jpeg'
    }
  end

  describe 'POST /gcs' do
    it 'returns http success', skip: 'Skipping test which calls Google Cloud, change code to run manually' do
      post '/gcs', params: sample_request, as: :json
      expect(response).to have_http_status(:success)
      expect(response.body.to_json).to match(a_string_including(sample_request[:file_name]))
    end
  end

  describe 'POST /gcs' do
    it 'returns http failure without params' do
      post '/gcs'
      expect(response).to have_http_status(422)
    end
  end
end
