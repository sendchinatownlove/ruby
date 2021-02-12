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

    it 'Returns a 200' do
      get '/auth/google'
      expect(response).to have_http_status(200)
    end
  end

  context 'POST /auth/passwordless' do
    let(:workos_passwordless_session) do
      WorkOS::Types::PasswordlessSessionStruct.new(
        id: 'passwordless_session',
        email: 'distributor@gmail.com',
        expires_at: Date.today,
        link: 'https://auth.workos.com/passwordless/id/confirm'
      )
    end

    before(:each) do
      allow(WorkOS::Passwordless).to receive(:create_session).with(any_args).and_return(
        workos_passwordless_session
      )
      allow(EmailManager::MagicLinkSender).to receive(:call)
    end

    it 'Creates a passwordless session via WorkOS' do
      expect(WorkOS::Passwordless).to receive(:create_session)
        .once
      post '/auth/passwordless'
    end

    it 'Sends an email' do
      expect(EmailManager::MagicLinkSender).to receive(:call)
        .once
        .with({
                email: workos_passwordless_session.email,
                magic_link_url: workos_passwordless_session.link
              })
      post(
        '/auth/passwordless',
        params: {
          email: 'distributor@gmail.com'
        },
        as: :json
      )
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
