# frozen_string_literal: true

module EmailManager
  class MagicLinkSender < BaseService
    attr_reader :email, :magic_link_url

    def initialize(params)
      @email = params[:email]
      @magic_link_url = params[:magic_link_url]
    end

    def call
      html = <<~EOF
        <!DOCTYPE html>
        <html>
          <head>
            <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
          </head>
          <body>
            <p>Your Magic Link</p>
            <p>
              You requested a Magic Link to sign into Send Chinatown Love.
              Click the link below to sign in!
              <a href="#{magic_link_url}" target="_blank">
                Send Chinatown Love
              </a>
            </p>
          </body>
        </html>
      EOF
      EmailManager::Sender.send_receipt(
        to: email,
        html: html,
        subject: 'Send Chinatown Love: Magic Link Sign-In'
      )
    rescue StandardError
      Rails.logger.error 'Magic Link e-mail errored out. ' \
              "email: #{email}"
    end
  end
end
