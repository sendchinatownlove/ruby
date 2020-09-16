# frozen_string_literal: true

module EmailManager
  class Sender < BaseService
    def self.format_amount(amount:)
      format('%<amount>.2f', amount: (amount.to_f / 100))
    end

    def self.send_receipt(to:,
                          html:,
                          subject: 'Receipt from Send Chinatown Love')
      api_key = ENV['MAILGUN_API_KEY']
      # rubocop:disable Layout/LineLength
      api_url = "https://api:#{api_key}@api.mailgun.net/v2/m.sendchinatownlove.com/messages"
      # rubocop:enable Layout/LineLength

      RestClient.post api_url,
                      from: 'receipts@sendchinatownlove.com',
                      to: to,
                      subject: subject,
                      html: html

      # Send to Receipts Eng so that they know what their receipts in prod looks like
      RestClient.post api_url,
                      from: 'receipts@sendchinatownlove.com',
                      to: 'receipts@sendchinatownlove.com',
                      subject: subject,
                      html: html
    end
  end
end
