# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/tickets', type: :request do
  # Setup models
  let(:participating_seller1) { create :participating_seller }
  let(:sponsor_seller1) { create :sponsor_seller }
  let(:contact1) { create :contact }
  let(:contact2) { create :contact }

  # Static attribute sets for testing
  let(:base_attributes) do
    {
      participating_seller: participating_seller1,
      ticket_id: 'AEIO-U'
    }
  end

  let(:base_attributes_with_contact) do
    {
      participating_seller: participating_seller1,
      ticket_id: 'AEIO-U',
      contact_id: contact1.id
    }
  end

  let(:create_attributes) do
    {
      participating_seller_id: participating_seller1.id,
      number_of_tickets: 1
    }
  end

  let(:create_ten_attributes) do
    {
      participating_seller_id: participating_seller1.id,
      number_of_tickets: 10
    }
  end

  let(:invalid_participating_seller_attributes) do
    {
      participating_seller_id: 100,
      number_of_tickets: 1
    }
  end

  let(:invalid_number_attributes) do
    {
      participating_seller_id: participating_seller1.id,
      number_of_tickets: -1
    }
  end

  let(:update_attributes) do
    {
      contact_id: contact2.id
    }
  end

  let(:update_additional_attributes) do
    {
      contact_id: contact2.id,
      ticket_id: 'new_id'
    }
  end

  let(:invalid_update_attributes) do
    {
      unexpected_property: 'value'
    }
  end

  # Tests
  describe 'GET /show' do
    it 'renders a successful response' do
      ticket = Ticket.create! base_attributes
      get ticket_url(ticket.ticket_id), as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Ticket' do
        expect do
          post tickets_url,
               params: create_attributes, as: :json
        end.to change(Ticket, :count).by(1)
      end

      it 'creates ten new Tickets' do
        expect do
          post tickets_url,
               params: create_ten_attributes, as: :json
        end.to change(Ticket, :count).by(10)
      end

      it 'renders a JSON response with the new ticket' do
        post tickets_url,
             params: create_attributes, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Ticket without a valid participating seller' do
        expect do
          post tickets_url,
               params: invalid_participating_seller_attributes, as: :json
        end.to change(Ticket, :count).by(0)
      end

      it 'renders a JSON response with errors for the new ticket without a valid participating seller' do
        post tickets_url,
             params: invalid_participating_seller_attributes, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including('application/json'))
      end

      it 'does not create a new Ticket without a valid number of tickets' do
        expect do
          post tickets_url,
               params: invalid_number_attributes, as: :json
        end.to change(Ticket, :count).by(0)
      end

      it 'renders a JSON response with errors for the new ticket without a valid number of tickets' do
        post tickets_url,
             params: invalid_number_attributes, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'PATCH /update' do
    before { freeze_time }
    context 'with valid parameters' do
      it 'updates the requested ticket with a valid contact' do
        ticket = Ticket.create! base_attributes
        put ticket_url(ticket.ticket_id),
            params: update_attributes, as: :json
        ticket.reload
        expect(ticket[:contact_id]).not_to be_nil
        expect(ticket[:associated_with_contact_at]).to eq(Time.now.as_json)
        expect(ticket[:contact_id]).to eq(contact2.id)
      end

      it 'renders a JSON response with the ticket with a valid contact' do
        ticket = Ticket.create! base_attributes
        put ticket_url(ticket.ticket_id),
            params: update_attributes, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end

      it 'overwrites contact appropriately' do
        ticket = Ticket.create! base_attributes_with_contact
        expect(ticket.contact_id).to eq(contact1.id)

        put ticket_url(ticket.ticket_id),
            params: update_attributes, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))

        body = JSON.parse response.body
        expect(body['contact_id']).to eq(contact2.id)
      end

      it 'does not change any attribute other than contact_id' do
        ticket = Ticket.create! base_attributes
        put ticket_url(ticket.ticket_id),
            params: update_attributes, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))

        body = JSON.parse response.body
        expect(body['ticket_id']).to eq(ticket.ticket_id)
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the ticket without a valid contact' do
        ticket = Ticket.create! base_attributes
        put ticket_url(ticket.ticket_id),
            params: invalid_update_attributes, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid ticket' do
      it 'renders a JSON response with errors for the ticket without a valid contact' do
        ticket = Ticket.create! base_attributes
        put ticket_url('oijawefo'),
            params: update_attributes, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
