# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contacts', type: :request do
  describe 'GET /contacts/:id' do
    let!(:contact) { create :contact, instagram: instagram }
    let(:instagram) { nil }
    let(:id) { contact.id }
    let(:attrs) do
      nil
    end
    subject do
      get(
        "/contacts/#{id}",
        params: attrs
      )
    end

    context 'with valid id' do
      it 'returns a 200' do
        subject
        expect(response).to have_http_status(200)
      end

      it 'returns the contact with only the id' do
        subject
        expect(json).to eq({
          id: contact.id,
          instagram: false,
          unique_seller_tickets: 0,
          weekly_giveaway_entries: 0,
          is_eligible_for_lyft_reward: false,
          lny_redepmtions: 0
        }.as_json)
      end

      context 'with instagram' do
        let(:instagram) { '@blah' }

        it 'returns a 200' do
          subject
          expect(response).to have_http_status(200)
        end

        it 'returns the contact with only the id' do
          subject
          expect(json).to eq({
            id: contact.id,
            instagram: true,
            unique_seller_tickets: 0,
            weekly_giveaway_entries: 0,
            is_eligible_for_lyft_reward: false,
            lny_redepmtions: 0
          }.as_json)
        end
      end

      context 'when is_eligible_for_lyft_reward is true for the contact' do
        before do
          allow_any_instance_of(Contact).to receive(:is_eligible_for_lyft_reward).and_return(true)
        end

        it 'returns the contact with is_eligible_for_lyft_reward set to true' do
          subject
          expect(json).to eq({
            id: contact.id,
            instagram: false,
            unique_seller_tickets: 0,
            weekly_giveaway_entries: 0,
            is_eligible_for_lyft_reward: true,
            lny_redepmtions: 0
          }.as_json)
        end
      end

      context 'with tickets at unique participating sellers' do
        let!(:ticket1) { create :ticket, contact: contact }
        let!(:ticket2) { create :ticket, contact: contact }
        let!(:ticket3) { create :ticket, contact: contact }
        let!(:ticket4) { create :ticket, contact: contact }
        let!(:ticket5) { create :ticket, contact: contact }

        it 'returns a 200' do
          subject
          expect(response).to have_http_status(200)
        end

        it 'returns the number of entries this contact has' do
          subject
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

        it 'returns a 200' do
          subject
          expect(response).to have_http_status(200)
        end

        it 'returns the number of tickets from unique participating sellers this contact has' do
          subject
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
          subject
          expect(response).to have_http_status(200)
        end

        it 'returns the contact with only the id' do
          subject
          expect(json).to eq({
            id: contact.id,
            instagram: true,
            unique_seller_tickets: 0,
            weekly_giveaway_entries: 0,
            is_eligible_for_lyft_reward: false,
            lny_redepmtions: 0
          }.as_json)
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
        expect(response.body).to match(/Couldn't find Contact/)
      end
    end
  end

  describe 'GET /contacts/:email' do
    let(:email) { 'bob@sendchinatownlove.com' }
    let!(:contact) { create :contact, instagram: nil, email: email }
    before do
      get(
        '/contacts',
        params: attrs
      )
    end

    context 'with the a valid email, in the same lowercase' do
      let(:attrs) do
        {
          email: email
        }
      end

      it 'returns a 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the contact with only the id' do
        expect(json.to_s).to include({ id: contact.id, instagram: false }.as_json.to_s.to_s[0..-2])
      end
    end

    context 'with the a valid email, in a different case' do
      let(:attrs) do
        {
          email: email.upcase
        }
      end

      it 'returns a 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the contact with only the id' do
        expect(json.to_s).to include({ id: contact.id, instagram: false }.as_json.to_s[0..-2])
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
          weekly_giveaway_entries: 0,
          is_eligible_for_lyft_reward: false,
          lny_redepmtions: 0
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
            weekly_giveaway_entries: 0,
            is_eligible_for_lyft_reward: false,
            lny_redepmtions: 0
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

    context 'with an uppercased email' do
      let(:attrs) do
        {
          name: 'Bob',
          instagram: '@sendchinatownlove',
          email: email.upcase
        }
      end

      it 'creates a lowercased new contact and returns it' do
        # It filters out the leading @
        contact = Contact.find_by(email: email, name: 'Bob', instagram: 'sendchinatownlove')

        expect(contact).to_not be_nil
        expect(json).to eq(contact.as_json)
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
