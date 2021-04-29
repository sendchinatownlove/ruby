# frozen_string_literal: true

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
      amount_string = EmailManager::Sender.format_amount(amount: amount)
      gift_card_url = 'https://merchant.sendchinatownlove.com/voucher/' + gift_card_detail.gift_card_id
      html = '<!DOCTYPE html>' \
           '<html>' \
           '<head>' \
           "  <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />" \
           '</head>' \
           '<body>' \
           '<h1>Thank you for your purchase from ' + merchant + '!</h1>' \
           '<p> We truly appreciate your donation to ' + merchant + '! While this year has been' \
           ' trying for Asian-owned small businesses, donors like you have stepped up to support our' \
           ' community in their time of need — resulting in $125,000 raised to date. </p>' \
           '<p> Please use the voucher linked below when making your purchase at this merchant.' \
           ' Thanks again for support. </p>' \
           '<p> With gratitude,<br>' \
           ' The Send Chinatown Love team</p>' \
           '<p><a href="' + gift_card_url + '"> Access Your Voucher</a><br>' \
           ' Voucher Balance: <b>$' + amount_string + '</b><br>' \
           '<a href="' + payment_intent.receipt_url + '"> View Your Square Receipt </a></p>' \
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
    # rubocop:enable Layout/LineLength
  end
end
