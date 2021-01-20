# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authorizations', type: :request do
  context 'GET /auth/google' do
    let(:redirect_url) { 'https://api.workos.com/sso/authorize?' }

    before(:each) do
      allow(WorkOS::SSO).to receive(:authorization_url).with(any_args).and_return(
        redirect_url
      )
    end

    it 'Generates an authorization url via WorkOS' do
      expect(WorkOS::SSO).to receive(:authorization_url).once
      get '/auth/google'
    end

    it 'Returns a 302' do
      get '/auth/google'
      expect(response).to have_http_status(302)
    end
  end

  context 'POST /auth/passwordless' do
    # TODO: This is a stub for now. Adding a custom SCL e-mail in a future PR.

    before(:each) do
      allow(WorkOS::Passwordless).to receive(:create_session).with(any_args).and_return(
        nil
      )
    end

    it 'Creates a passwordless session via WorkOS' do
      expect(WorkOS::Passwordless).to receive(:create_session)
        .once
      post '/auth/passwordless'
    end
  end

  context 'GET /auth/callback' do
    before(:each) do
      allow(WorkOS::SSO).to receive(:profile).with(any_args).and_return(
        {
          'id' => 'profile_id'
        }
      )
    end

    it 'Returns a 302' do
      get '/auth/callback'
      expect(response).to have_http_status(302)
    end
  end
end
