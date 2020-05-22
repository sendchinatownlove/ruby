
module Emails
  # rubocop:disable Layout/LineLength
  def send_pool_donation_receipt(payment_intent:, amount:)
    amount_string = format_amount(amount: amount)
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
    send_receipt(to: payment_intent.recipient.email, html: html)
  end

  def send_donation_receipt(payment_intent:, amount:, merchant:)
    amount_string = format_amount(amount: amount)
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
    send_receipt(to: payment_intent.recipient.email, html: html)
  end

  def send_gift_card_receipt(payment_intent:, amount:, merchant:, receipt_id:)
    amount_string = format_amount(amount: amount)
    html = '<!DOCTYPE html>' \
           '<html>' \
           '<head>' \
           "  <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />" \
           '</head>' \
           '<body>' \
           '<h1>Thank you for your purchase from ' + merchant + '!</h1>' \
           '<p> Gift card code: <b>' + receipt_id + '</b></p>' \
           '<p> Gift card balance: <b>$' + amount_string + '</b></p>' \
           '<p> Square receipt: ' + payment_intent.receipt_url + '</p>' \
           "<p> We'll be in touch when " + merchant + ' opens back up with details' \
           '  on how to use your gift card. Sending thanks from us and from Chinatown for' \
           '  your support! </p>' \
           '<p> Love,<p>' \
           '<p> the Send Chinatown Love team</p>' \
           '</body>' \
           '</html>'
    send_receipt(to: payment_intent.recipient.email, html: html)
  end

  def format_amount(amount:)
    format('%<amount>.2f', amount: (amount.to_f / 100))
  end

  def send_receipt(to:, html:)
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
  # rubocop:enable Layout/LineLength
end
