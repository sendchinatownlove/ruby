# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fees', type: :request do

let!(:fee) { create :fee }

  context 'GET /fees' do
    before { get "/fees" }
    context 'with fees' do

      it 'returns fees' do
        fees = JSON.parse(response.body)
        expect(fees.size).to eq 1
        expect(fees[0]['id']).to eq fee.id
      end

      it 'returns 200' do
        expect(response.response_code).to eq 200
      end
    end

  end

  context 'POST /fees' do
    let!(:campaign) { create :campaign }
    let(:response) { post :create, params: params, as: :json }

    context 'with campaign_id' do
      let(:params) do
        {
        }
      end

      it 'creates a fee with default values' do
        response_body = JSON.parse(response.body)
        expect(response_body).not_to be_nil

        fee = Fee.find(response_body['id'])
        fee.campaigns << campaign
        expect(fee).not_to be_nil
        expect(fee.campaigns.size).to eq 1
        expect(fee.multiplier).to eq 0.0
        expect(fee.flat_cost).to eq 0.0
        expect(fee.active).to eq true
      end

      it 'returns 201' do
        expect(response.response_code).to eq 201
      end
    end

    context 'with all parameters' do
      let(:params) do
        {
          multiplier: 0.03,
          flat_cost: 0.30,
          description: 'square fee',
          active: false
        }
      end

      it 'creates a fee with provided parameters' do
        response_body = JSON.parse(response.body)
        expect(response_body).not_to be_nil

        fee = Fee.find(response_body['id'])
        fee.campaigns << campaign
        expect(fee).not_to be_nil
        expect(fee.campaigns.size).to eq 1
        expect(fee.multiplier).to eq 0.03
        expect(fee.flat_cost).to eq 0.30
        expect(fee.active).to eq false
      end

      it 'returns 201' do
        expect(response.response_code).to eq 201
      end
    end

    context 'with extra parameters' do
      let(:params) do
        {
          multiplier: 0.03,
          flat_cost: 0.30,
          description: 'square fee',
          active: false,
          name: 'no, this is patrick'
        }
      end

      it 'only creates with the provided parameters' do
        response_body = JSON.parse(response.body)
        expect(response_body).not_to be_nil

        fee = Fee.find(response_body['id'])
        fee.campaigns << campaign
        expect(fee).not_to be_nil
        expect(fee.campaigns.size).to eq 1
        expect(fee.multiplier).to eq 0.03
        expect(fee.flat_cost).to eq 0.30
        expect(fee.active).to eq false
      end

      it 'returns 201' do
        expect(response.response_code).to eq 201
      end
    end
  end

  context 'PUT /fees/:id' do
    let!(:campaign) { create :campaign }
    let(:original_active) { true }
    let(:original_multiplier) { 0.03 }
    let(:original_flat_cost) {0.30}
    let(:original_description) { 'square fee'}
    let!(:fee) do
      create :fee, multiplier: original_multiplier, active: original_active, flat_cost: original_flat_cost, description: original_description
    end
    let(:response) { put :update, params: params, as: :json }

    it 'creates fee' do
      expect(fee.active).to eq original_active
      expect(fee.multiplier).to eq original_multiplier
      expect(fee.flat_cost).to eq original_flat_cost
      expect(fee.description).to eq original_description
      expect(fee.campaigns.size).to eq 0
    end

    context 'with invalid id' do
      let(:params) do
        {
          id: -1
        }
      end

      it 'returns 404' do
        expect(response.response_code).to eq 404
      end
    end

    context 'with valid id' do
      let(:id) { fee.id }

      context 'with all parameters' do
        let(:active) { false }
        let(:params) do
          {
            id: id,
            active: active
          }
        end

        it 'updates the fee with provided parameters' do
          expect(response.response_code).to eq 200
          fee = Fee.find(id)
          expect(fee.active).to eq active
        end
      end

      context 'with multiplier' do
        let(:active) { false }
        let(:params) do
          {
            id: id,
            active: active
          }
        end
        let(:multiplier) { 0.1 }
        it 'ignores updates to multiplier' do
          expect(response.response_code).to eq 200
          fee = Fee.find(id)
          expect(fee.multiplier).to eq original_multiplier
          expect(fee.campaigns.size).to eq 0
          expect(fee.active).to eq active
        end
      end
    end
  end
end
