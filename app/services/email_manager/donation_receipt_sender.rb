module EmailManager
  class DonationReceiptSender < BaseService
    attr_reader :amount, :merchant, :payment_intent

    def initialize(params)
      @amount = params[:amount]
      @merchant = params[:merchant]
      @payment_intent = params[:payment_intent]
    end

    # rubocop:disable Layout/LineLength
    def call
      begin
        amount_string = EmailManager::Sender.format_amount(amount: amount)
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
        EmailManager::Sender.send_receipt(to: payment_intent.recipient.email, html: html)
      rescue StandardError
        Rails.logger.error 'Donation email errored out. ' \
                "email: #{payment_intent.recipient.email}, " \
                "receipt: #{payment_intent.receipt_url} " \
                "amount: #{amount}, merchant: #{merchant}"
      end
    end
    # rubocop:enable Layout/LineLength
  end
end
