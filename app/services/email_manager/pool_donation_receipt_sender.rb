# frozen_string_literal: true

module EmailManager
  class PoolDonationReceiptSender < BaseService
    attr_reader :amount, :payment_intent

    def initialize(params)
      @amount = params[:amount]
      @payment_intent = params[:payment_intent]
    end

    # rubocop:disable Layout/LineLength
    def call
      amount_string = EmailManager::Sender.format_amount(amount: amount)
      html = '<!DOCTYPE html>' \
           '<html>' \
           '<head>' \
           "  <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />" \
           '</head>' \
           '<body>' \
           '<h1>Thank you for your donation to Send Chinatown Love!</h1>' \
           '<p> Donation amount: <b>$' + amount_string + '</b></p>' \
           '<p> Square receipt: ' + payment_intent.receipt_url + '</p>' \
           '<p> Your donation will be distributed evenly between our merchants. Sending ' \
           '  thanks from us and from Chinatown for your support! </p>' \
           '<p> Love,<p>' \
           '<p> the Send Chinatown Love team</p>' \
           '</body>' \
           '</html>'
      EmailManager::Sender.send_receipt(to: payment_intent.recipient.email, html: html)
    rescue StandardError
      Rails.logger.error 'Pool donation email errored out. ' \
            "email: #{payment_intent.recipient.email}, " \
            "receipt: #{payment_intent.receipt_url} " \
            "amount: #{amount}"
    end
    # rubocop:enable Layout/LineLength
  end
end
