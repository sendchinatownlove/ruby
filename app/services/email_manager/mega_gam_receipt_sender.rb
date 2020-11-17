# frozen_string_literal: true

module EmailManager
  class MegaGamReceiptSender < BaseService
    attr_reader :amount, :campaign_name, :payment_intent

    def initialize(params)
      @amount = params[:amount]
      @campaign_name = params[:campaign_name]
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
            '<h1>Thank you for your donation to ' + campaign_name + '!</h1>' \
            '<p> Donation amount: <b>$' + amount_string + '</b></p>' \
            '<p> Square receipt: ' + payment_intent.receipt_url + '</p>' \
            '<p> Sending thanks from us and from Chinatown for your support! </p>' \
            '<p> Love,<p>' \
            '<p> Send Chinatown Love</p>' \
            '</body>' \
            '</html>'
      EmailManager::Sender.send_receipt(to: payment_intent.purchaser.email, html: html)
    rescue StandardError
      Rails.logger.error 'Mega GAM donation email errored out. ' \
              "email: #{payment_intent.purchaser.email}, " \
              "receipt: #{payment_intent.receipt_url} " \
              "amount: #{amount}, campaign_name: #{campaign_name}"
    end
    # rubocop:enable Layout/LineLength
  end
end
