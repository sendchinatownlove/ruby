# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contacts', type: :request do
  describe 'GET /contacts/:id' do
    let!(:contact) { create :contact, instagram: instagram }
    let(:instagram) { nil }
    let(:id) { contact.id }
    before do
      get(
        "/contacts/#{id}",
        params: attrs
      )
    end
    let(:attrs) do
      nil
    end

    context 'with valid id' do
      it 'returns a 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the contact with only the id' do
        expect(json).to eq({
          id: contact.id,
          instagram: false,
          unique_seller_tickets: 0,
          weekly_giveaway_entries: 0
        }.as_json)
      end

      context 'with instagram' do
        let(:instagram) { '@blah' }

        it 'returns a 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns the contact with only the id' do
          expect(json).to eq({
            id: contact.id,
            instagram: true,
            unique_seller_tickets: 0,
            weekly_giveaway_entries: 0
          }.as_json)
        end
      end

      context 'with tickets at unique participating sellers' do
        let!(:ticket1) { create :ticket, contact: contact }
        let!(:ticket2) { create :ticket, contact: contact }
        let!(:ticket3) { create :ticket, contact: contact }
        let!(:ticket4) { create :ticket, contact: contact }
        let!(:ticket5) { create :ticket, contact: contact }

        before do
          # TODO(justintmckibben): Makes the request twice for this test.
          #                        Restructure this test to only make this call
          #                        once.
          get(
            "/contacts/#{id}",
            params: attrs
          )
        end

        it 'returns a 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns the number of entries this contact has' do
          expect(json['weekly_giveaway_entries']).to eq(1)
        end
      end

      context 'with tickets with some revisits' do
        let!(:particpiating_seller1) { create :participating_seller }
        let!(:particpiating_seller2) { create :participating_seller }
        let!(:particpiating_seller3) { create :participating_seller }
        let!(:particpiating_seller4) { create :participating_seller }
        let!(:ticket1) { create :ticket, contact: contact, participating_seller: particpiating_seller1 }
        let!(:ticket2) { create :ticket, contact: contact, participating_seller: particpiating_seller2 }
        let!(:ticket3) { create :ticket, contact: contact, participating_seller: particpiating_seller3 }
        let!(:ticket4) { create :ticket, contact: contact, participating_seller: particpiating_seller4 }
        let!(:ticket5) { create :ticket, contact: contact, participating_seller: particpiating_seller4 }

        before do
          # TODO(justintmckibben): Makes the request twice from the earlier
          #                        context.
          #                        Restructure this test to only make this call
          #                        once.
          get(
            "/contacts/#{id}",
            params: attrs
          )
        end

        it 'returns a 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns the number of tickets from unique participating sellers this contact has' do
          expect(json['unique_seller_tickets']).to eq(4)
        end
      end

    end

    context 'with random attributes' do
      let(:attrs) do
        {
          email: 'blargh'
        }
      end

      context 'with instagram' do
        let(:instagram) { '@blah' }

        it 'returns a 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns the contact with only the id' do
          expect(json).to eq({
            id: contact.id,
            instagram: true,
            unique_seller_tickets: 0,
            weekly_giveaway_entries: 0 }.as_json)
        end
      end
    end

    context 'with invalid id' do
      let(:id) { 9999 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Contact/)
      end
    end
  end

  describe 'GET /contacts' do
    let!(:contact) { create :contact, instagram: instagram }
    let(:instagram) { nil }
    before do
      get(
        '/contacts',
        params: attrs
      )
    end
    let(:email) { contact.email }

    let(:attrs) do
      {
        email: email
      }
    end

    context 'with valid email' do
      it 'returns a 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the contact with only the id' do
        expect(json).to eq({
          id: contact.id,
          instagram: false,
          unique_seller_tickets: 0,
          weekly_giveaway_entries: 0
        }.as_json)
      end

      context 'with instagram' do
        let(:instagram) { '@blah' }

        it 'returns a 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns the contact with only the id' do
          expect(json).to eq({
            id: contact.id,
            instagram: true,
            unique_seller_tickets: 0,
            weekly_giveaway_entries: 0
          }.as_json)
        end
      end
    end

    context 'with invalid email' do
      let(:email) { 'invalid-email@email.com' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Contact/)
      end
    end

    context 'without email' do
      let(:attrs) do
        nil
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a missing param message' do
        expect(response.body).to match(/param is missing or the value is empty: email/)
      end
    end
  end

  describe 'POST /contacts' do
    before do
      post(
        '/contacts',
        params: attrs,
        as: :json
      )
    end
    let(:email) { 'bob@sendchinatownlove.com' }

    let(:attrs) do
      {
        email: email,
        name: 'Bob',
        instagram: '@sendchinatownlove'
      }
    end

    it 'creates a new contact and returns it' do
      # It filters out the leading @
      contact = Contact.find_by(email: email, name: 'Bob', instagram: 'sendchinatownlove')

      expect(contact).to_not be_nil
      expect(json).to eq(contact.as_json)
    end

    it 'returns a 201' do
      expect(response).to have_http_status(201)
    end

    context 'with email that already exists' do
      before do
        # Try to create another contact with the same email
        post(
          '/contacts',
          params: attrs,
          as: :json
        )
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a missing param message' do
        expect(response.body).to match(/Validation failed: Email has already been taken/)
      end
    end

    context 'without email' do
      let(:attrs) do
        {
          name: 'Bob',
          instagram: '@sendchinatownlove'
        }
      end
      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a missing param message' do
        expect(response.body).to match(/param is missing or the value is empty: email/)
      end
    end

    context 'with extra parameters' do
      let(:attrs) do
        {
          email: email,
          name: 'Bob',
          instagram: '@sendchinatownlove',
          rewards_redemption_access_token: 'oiajwefoijawefoj'
        }
      end

      it 'creates a new contract without extra parameters and returns it' do
        # It filters out the leading
        contact = Contact.find_by(email: email, name: 'Bob', instagram: 'sendchinatownlove')

        expect(contact).to_not be_nil
        expect(json).to eq(contact.as_json)
      end

      it 'returns a 201' do
        expect(response).to have_http_status(201)
      end
    end
  end

  describe 'PUT /contacts/:id' do
    let!(:contact) { create :contact }
    let(:id) { contact.id }

    before do
      # Try to create another contact with the same email
      put(
        "/contacts/#{id}",
        params: attrs,
        as: :json
      )
    end

    let(:attrs) do
      {
        email: 'bob@sendchinatownlove.com',
        name: 'Bob',
        instagram: '@sendchinatownlove'
      }
    end

    context 'with valid id' do
      it 'returns a 200' do
        expect(response).to have_http_status(200)
      end

      it 'updates the contact' do
        # It filters out the leading @
        contact = Contact.find_by(email: 'bob@sendchinatownlove.com', name: 'Bob', instagram: 'sendchinatownlove')

        expect(contact).to_not be_nil
        expect(json).to eq(
          contact.as_json.slice('id', 'email', 'instagram', 'name')
        )
      end

      context 'with extra parameters' do
        let(:attrs) do
          {
            email: 'bob@sendchinatownlove.com',
            name: 'Bob',
            instagram: '@sendchinatownlove',
            rewards_redemption_access_token: 'secret'
          }
        end

        it 'updates the contact with only valid parameters' do
          # It filters out the leading @
          contact = Contact.find_by(email: 'bob@sendchinatownlove.com', name: 'Bob', instagram: 'sendchinatownlove')

          expect(contact).to_not be_nil
          expect(json).to eq(
            contact.as_json.slice('id', 'email', 'instagram', 'name')
          )
        end

        it 'returns a 200' do
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'with invalid id' do
      let(:id) { 999_999 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Contact/)
      end
    end
  end
end
