# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Projects', type: :request do
  describe 'GET /projects/' do
    subject do
      get '/projects/'
    end

    it 'return a 200' do
      subject
      expect(response).to have_http_status(200)
    end

    it 'returns no elements as a response' do
      subject

      expect(json).to eq([])
    end

    context 'with 1 project' do
      let!(:project1) do
        Project.create(square_location_id: 'oinawefoijwaef', name: 'project 1')
      end

      it 'return a 200' do
        subject
        expect(response).to have_http_status(200)
      end

      it 'expect there to be a single project' do
        subject
        expect(json.size).to eq 1
      end
    end

    context 'with 3 projects' do
      let!(:project1) do
        Project.create(square_location_id: 'oinawefoijwaef', name: 'project 1')
      end

      let!(:project2) do
        Project.create(square_location_id: 'oijawef', name: 'project 2')
      end

      let!(:project3) do
        Project.create(square_location_id: 'oinawefoijwaef', name: 'project 3')
      end

      it 'return a 200' do
        subject
        expect(response).to have_http_status(200)
      end

      it 'expect there to be 3 projects' do
        subject
        expect(json.size).to eq 3
      end
    end
  end

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
