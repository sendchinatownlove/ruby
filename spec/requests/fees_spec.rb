# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fees API', type: :request do
  context 'GET /fees' do
    context 'with fees' do
      let!(:fee) { create :fee }
      before { get '/fees' }

      it 'returns fees' do
        expect(json).not_to be_empty
        expect(json.size).to eq(1)
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'without fees' do
      before { get '/fees' }

      it 'returns no fees' do
        expect(json).to be_empty
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end
    end
  end
end
