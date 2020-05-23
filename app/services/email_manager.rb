# frozen_string_literal: true

module EmailManager
  def self.format_amount(amount:)
    format('%<amount>.2f', amount: (amount.to_f / 100))
  end

  def self.send_receipt(to:, html:)
    api_key = ENV['MAILGUN_API_KEY']
    api_url = "https://api:#{api_key}@api.mailgun.net/v2/m.sendchinatownlove.com/messages"

    RestClient.post api_url,
                    from: 'receipts@sendchinatownlove.com',
                    to: to,
                    subject: 'Receipt from Send Chinatown Love',
                    html: html

    # Send to Receipts Eng so that they know what their receipts in prod looks
    # like
    RestClient.post api_url,
                    from: 'receipts@sendchinatownlove.com',
                    to: 'receipts@sendchinatownlove.com',
                    subject: 'Receipt from Send Chinatown Love',
                    html: html
  end

  # rubocop:disable Layout/LineLength
  class DonationReceiptEmailSender < BaseService
    attr_reader :logger, :amount, :merchant, :payment_intent

    def initialize(params)
      @logger = Rails.logger
      @amount = params[:amount]
      @merchant = params[:merchant]
      @payment_intent = params[:payment_intent]
    end

    def call
      begin
        amount_string = EmailManager::format_amount(amount: amount)
        html = '<!DOCTYPE html>' \
           '<html>' \
           '<head>' \
           "  <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />" \
           '</head>' \
           '<body>' \
           '<h1>Thank you for your donation to ' + merchant + '!</h1>' \
           '<p> Donation amount: <b>$' + amount_string + '</b></p>' \
           '<p> Square receipt: ' + payment_intent.receipt_url + '</p>' \
           "<p> We'll be in touch when " + merchant + ' opens back up. Sending ' \
           '  thanks from us and from Chinatown for your support! </p>' \
           '<p> Love,<p>' \
           '<p> the Send Chinatown Love team</p>' \
           '</body>' \
           '</html>'
        EmailManager::send_receipt(to: payment_intent.recipient.email, html: html)
      rescue StandardError
        logger.error 'Donation email errored out. ' \
              "email: #{payment_intent.recipient.email}, " \
              "receipt: #{payment_intent.receipt_url} " \
              "amount: #{amount}, merchant: #{merchant}"
      end
    end
  end

  class PoolDonationReceiptEmailSender < BaseService
    attr_reader :logger, :amount, :payment_intent

    def initialize(params)
      @logger = Rails.logger
      @amount = params[:amount]
      @payment_intent = params[:payment_intent]
    end

    def call
      begin
        amount_string = EmailManager::format_amount(amount: amount)
        html = '<!DOCTYPE html>' \
           '<html>' \
           '<head>' \
           "  <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />" \
           '</head>' \
           '<body>' \
           '<h1>Thank you for your donation to Send Chinatown Love!</h1>' \
           '<p> Donation amount: <b>$' + amount_string + '</b></p>' \
           '<p> Square receipt: ' + payment_intent.receipt_url + '</p>' \
           '<p> You\'re donation will be distributed evenly between our merchants. Sending ' \
           '  thanks from us and from Chinatown for your support! </p>' \
           '<p> Love,<p>' \
           '<p> the Send Chinatown Love team</p>' \
           '</body>' \
           '</html>'
        EmailManager::send_receipt(to: payment_intent.recipient.email, html: html)
      rescue StandardError
        logger.error 'Pool donation email errored out. ' \
            "email: #{payment_intent.recipient.email}, " \
            "receipt: #{payment_intent.receipt_url} " \
            "amount: #{amount}"
      end
    end
  end

  class GiftCardReceiptEmailSender < BaseService
    attr_reader :logger, :amount, :gift_card_detail, :merchant, :payment_intent

    def initialize(params)
      @logger = Rails.logger
      @amount = params[:amount]
      @gift_card_detail = params[:gift_card_detail]
      @merchant = params[:merchant]
      @payment_intent = params[:payment_intent]
    end

    def call
      begin
        amount_string = EmailManager::format_amount(amount: amount)
        html = '<!DOCTYPE html>' \
           '<html>' \
           '<head>' \
           "  <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />" \
           '</head>' \
           '<body>' \
           '<h1>Thank you for your purchase from ' + merchant + '!</h1>' \
           '<p> Gift card code: <b>' + gift_card_detail.seller_gift_card_id + '</b></p>' \
           '<p> Gift card balance: <b>$' + amount_string + '</b></p>' \
           '<p> Square receipt: ' + payment_intent.receipt_url + '</p>' \
           "<p> We'll be in touch when " + merchant + ' opens back up with details' \
           '  on how to use your gift card. Sending thanks from us and from Chinatown for' \
           '  your support! </p>' \
           '<p> Love,<p>' \
           '<p> the Send Chinatown Love team</p>' \
           '</body>' \
           '</html>'
        EmailManager::send_receipt(to: payment_intent.recipient.email, html: html)
      rescue StandardError
        logger.error 'Gift card email errored out. ' \
              "email: #{payment_intent.recipient.email}, " \
              "receipt: #{payment_intent.receipt_url} " \
              "amount: #{amount}, " \
              "merchant: #{merchant}, " \
              "receipt_id: #{gift_card_detail.seller_gift_card_id}, " \
              "gift card detail: #{gift_card_detail}"
      end
    end
  end
  # rubocop:enable Layout/LineLength
end
