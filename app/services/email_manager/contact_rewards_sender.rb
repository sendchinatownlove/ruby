# frozen_string_literal: true

module EmailManager
  class ContactRewardsSender < BaseService
    attr_reader :contact_id, :email, :token

    def initialize(params)
      @contact_id = params[:contact_id]
      @email = params[:email]
      @token = params[:token]
    end

    # rubocop:disable Layout/LineLength
    def call
      redemption_url = 'https://merchant.sendchinatownlove.com/passport/' + contact_id.to_s \
        + '/redeem/' + token
      html = '<!DOCTYPE html>' \
           '<html>' \
           '<head>' \
           "  <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />" \
           '</head>' \
           '<body>' \
           '<p> Ticket Redemption URL: ' + redemption_url + '</p>' \
           '<p> Sending thanks from us and from Chinatown for your support! </p>' \
           '<p> Love,<p>' \
           '<p> Send Chinatown Love</p>' \
           '</body>' \
           '</html>'
      EmailManager::Sender.send_receipt(to: email, html: html)
    rescue StandardError
      Rails.logger.error 'Passport redemption e-mail errored out. ' \
              "email: #{email}"
    end
    # rubocop:enable Layout/LineLength
  end
end
