module EmailManager
  class GiftCardReceiptSender < BaseService
    attr_reader :amount, :gift_card_detail, :merchant, :payment_intent

    def initialize(params)
      @amount = params[:amount]
      @gift_card_detail = params[:gift_card_detail]
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
        EmailManager::Sender.send_receipt(to: payment_intent.recipient.email, html: html)
      rescue StandardError
        Rails.logger.error 'Gift card email errored out. ' \
                "email: #{payment_intent.recipient.email}, " \
                "receipt: #{payment_intent.receipt_url} " \
                "amount: #{amount}, " \
                "merchant: #{merchant}, " \
                "receipt_id: #{gift_card_detail.seller_gift_card_id}, " \
                "gift card detail: #{gift_card_detail}"
      end
    end
    # rubocop:enable Layout/LineLength
  end
end
