# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fees', type: :request do

  describe 'GET /fees' do
    let!(:fee) { create :fee }
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

  describe 'POST /fees' do
    let!(:campaign) { create :campaign }

    before do
      post(
        '/fees',
        params: attrs,
        as: :json
      )
    end

    context 'with only a description' do
      let(:attrs) do
        {
          description: 'test fee',
        }
      end

      it 'creates a fee with default values' do
        fee = Fee.find(json['id'])
        fee.campaigns << campaign

        expect(fee).to_not be_nil
        expect(json).to eq(fee.as_json)
        
        expect(fee).not_to be_nil
        expect(fee.campaigns.size).to eq 1
        expect(campaign.fees.size).to eq 1
        expect(fee.multiplier).to eq 0.0
        expect(fee.flat_cost).to eq 0.0
        expect(fee.active).to eq true
      end

      it 'returns 201' do
        expect(response.response_code).to eq 201
      end
    end

    context 'with all parameters' do
      let(:attrs) do
        {
          multiplier: 0.03,
          flat_cost: 0.30,
          description: 'square fee',
          active: false
        }
      end

      it 'creates a fee with provided parameters' do
        fee = Fee.find(json['id'])
        fee.campaigns << campaign

        expect(fee).to_not be_nil
        expect(json).to eq(fee.as_json)

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
      let(:attrs) do
        {
          multiplier: 0.03,
          flat_cost: 0.30,
          description: 'square fee',
          active: false,
          name: 'no, this is patrick'
        }
      end

      it 'only creates with the provided parameters' do
        fee = Fee.find(json['id'])
        fee.campaigns << campaign

        expect(fee).to_not be_nil
        expect(json).to eq(fee.as_json)

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

  describe 'PUT /fees/:id' do
    let(:original_active) { true }
    let(:original_multiplier) { 0.03 }
    let(:original_flat_cost) {0.30}
    let(:original_description) { 'square fee'}
    let!(:fee) do
      create :fee, multiplier: original_multiplier, active: original_active, flat_cost: original_flat_cost, description: original_description
    end
    let(:id) { fee.id }

    before do
      put(
        "/fees/#{id}",
        params: attrs,
        as: :json
      )
    end

    context 'with valid id' do
      let(:id) { fee.id }

      context 'with all parameters' do
        let(:attrs) do
          {
            id: id,
            active: false
          }
        end

        it 'updates the fee with provided parameters' do
          expect(response.response_code).to eq 200
          fee = Fee.find(id)
          expect(fee.active).to eq false
        end
      end

      context 'with multiplier' do
        let(:attrs) do
          {
            id: id,
            active: false,
            multiplier: 0.01
          }
        end
        it 'ignores updates to multiplier' do
          expect(response.response_code).to eq 200
          fee = Fee.find(id)
          expect(fee.multiplier).to eq original_multiplier
          expect(fee.campaigns.size).to eq 0
          expect(fee.active).to eq false
        end
      end
    end
  end
end
