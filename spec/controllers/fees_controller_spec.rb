# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeesController, type: :controller do
  context 'GET /fees' do
    let(:response) { get :index }
    context 'with fees' do
      let!(:fee) { create :fee }

      it 'returns fees' do
        fees = JSON.parse(response.body)
        expect(fees.size).to eq 1
        expect(fees[0]['id']).to eq fee.id
      end

      it 'returns 200' do
        expect(response.response_code).to eq 200
      end
    end

    context 'without fees' do
      it 'returns no fees' do
        fees = JSON.parse(response.body)
        expect(fees.size).to eq 0
      end

      it 'returns 200' do
        expect(response.response_code).to eq 200
      end
    end
  end

  context 'POST /fees' do
    let!(:seller) { create :seller }
    let(:response) { post :create, params: params, as: :json }
    context 'without seller_id' do
      let(:params) do
        {
          multiplier: 0.1,
          active: true
        }
      end

      it 'returns 422' do
        expect(response.response_code).to eq 422
      end
    end

    context 'with seller_id' do
      let(:params) do
        {
          seller_id: seller.seller_id
        }
      end

      it 'creates a fee with default values' do
        response_body = JSON.parse(response.body)
        expect(response_body).not_to be_nil

        fee = Fee.find(response_body['id'])
        expect(fee).not_to be_nil
        expect(fee.seller).to eq seller

        expect(fee.multiplier).to eq 0
        expect(fee.active).to eq true
      end

      it 'returns 201' do
        expect(response.response_code).to eq 201
      end
    end

    context 'with all parameters' do
      let(:params) do
        {
          seller_id: seller.seller_id,
          multiplier: 0.1,
          active: false
        }
      end

      it 'creates a fee with provided parameters' do
        response_body = JSON.parse(response.body)
        expect(response_body).not_to be_nil

        fee = Fee.find(response_body['id'])
        expect(fee).not_to be_nil
        expect(fee.seller).to eq seller

        expect(fee.multiplier).to eq 0.1
        expect(fee.active).to eq false
      end

      it 'returns 201' do
        expect(response.response_code).to eq 201
      end
    end

    context 'with extra parameters' do
      let(:params) do
        {
          seller_id: seller.seller_id,
          multiplier: 0.1,
          active: false,
          name: 'no, this is patrick'
        }
      end

      it 'only creates with the provided parameters' do
        response_body = JSON.parse(response.body)
        expect(response_body).not_to be_nil

        fee = Fee.find(response_body['id'])
        expect(fee).not_to be_nil
        expect(fee.seller).to eq seller

        expect(fee.multiplier).to eq 0.1
        expect(fee.active).to eq false
      end

      it 'returns 201' do
        expect(response.response_code).to eq 201
      end
    end
  end

  context 'PUT /fees/:id' do
    let!(:seller) { create :seller }
    let(:original_active) { true }
    let(:original_multiplier) { 0.2 }
    let!(:fee) do
      create :fee, multiplier: original_multiplier, active: original_active
    end
    let(:response) { put :update, params: params, as: :json }

    it 'creates fee' do
      expect(fee.active).to eq original_active
      expect(fee.multiplier).to eq original_multiplier
      expect(fee.seller).not_to eq seller
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
            seller_id: seller.seller_id,
            active: active
          }
        end

        it 'updates the fee with provided parameters' do
          expect(response.response_code).to eq 200
          fee = Fee.find(id)
          expect(fee.seller).to eq seller
          expect(fee.active).to eq active
        end
      end

      context 'with multiplier' do
        let(:active) { false }
        let(:params) do
          {
            id: id,
            seller_id: seller.seller_id,
          }
        end
        let(:multiplier) { 0.1 }
        it 'ignores updates to multiplier' do
          expect(response.response_code).to eq 200
          fee = Fee.find(id)
          expect(fee.multiplier).to eq original_multiplier
          expect(fee.seller).to eq seller
          expect(fee.active).to eq original_active
        end
      end
    end
  end
end
