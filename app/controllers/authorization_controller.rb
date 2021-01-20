# frozen_string_literal: true

class AuthorizationController < ApplicationController
  def google
    authorization_url = WorkOS::SSO.authorization_url(
      provider: 'GoogleOAuth',
      project_id: ENV['WORKOS_CLIENT_ID'],
      redirect_uri: "#{ENV['SENDCHINATOWNLOVE_API_URL']}/auth/callback"
    )
    redirect_to authorization_url
  end

  def passwordless
    session = WorkOS::Passwordless.create_session(
      type: 'MagicLink',
      email: params[:email]
    )

    # TODO: Add redirect and send e-mail.
  end

  def callback
    profile = WorkOS::SSO.profile(
      code: params['code'],
      project_id: ENV['WORKOS_CLIENT_ID']
    )

    session[:user] = profile.to_json

    redirect_to '/'
  end
end
