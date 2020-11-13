require 'rails_helper'

RSpec.describe "Projects", type: :request do

  describe 'GET /projects/:id' do
    let!(:project) { create :project }
    let(:id) { project.id }
    subject do
      get("/projects/#{id}")
    end

    context 'with valid id' do
      it 'returns a 200' do
        subject
        expect(response).to have_http_status(200)
      end

      it 'returns amount_raised as 0' do
        subject
        expect(json['amount_raised']).to eq(0)
      end

      context 'with payment intents' do
        let!(:payment_intent1) { create :payment_intent, :with_line_items, project: project, successful: true }
        let!(:payment_intent2) { create :payment_intent, :with_line_items, project: project, successful: false }
        let!(:payment_intent3) { create :payment_intent, project: project, successful: true }

        it 'returns a 200' do
          subject
          expect(response).to have_http_status(200)
        end

        it 'returns amount_raised' do
          subject
          expect(json['amount_raised']).to eq(600)
        end
      end
    end

    context 'with invalid id' do
      let(:id) { 9999 }

      it 'returns status code 404' do
        subject
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        subject
        expect(response.body).to match(/Couldn't find Project/)
      end
    end
  end
end
