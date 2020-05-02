# frozen_string_literal: true
require 'rest-client'

# TODO(jmckibben): This class needs a lot of refactoring
class WebhooksController < ApplicationController
  # POST /webhooks
  def create

    api_key = "" # Insert API key here
    api_url = "https://api:#{api_key}@api.mailgun.net/v2/m.sendchinatownlove.com/messages"

    amount = 500
    merchant = "Joolie's Bakery"
    # receipt_id = "blerghllejs"
    # receipt_url = "coolmath.com"

    amount_string = '%.2f' % ((amount.to_f)/100)

    html = "<!DOCTYPE html>" +
        "<!DOCTYPE html>" +
        "<html>" +
        " <head>" +
        "   <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />" +
        " </head>" +
        " <body style=\"margin: auto; text-align: center;\">" +
        " <div style=\"font-family: 'open sans', Roboto, Tahoma, 'Segoe UI', 'Gill Sans', Geneva, Verdana, sans-serif; text-align: center; margin: auto; color: #A8192E; background-color: #A8192E; margin: 0px; max-width: 600px;\">" +
        "   <img src='cid:mailer_header.png' style=\"width: 100%; overflow: hidden;\"/>" +
        "   <div style=\"height: 100%; padding: 8%;\">" +
        "     <div style=\"background-color: #FFFFFF; height: 100%; width: 100%; border-radius: 35px; padding: 5% 10%; box-sizing: border-box;\">" +
        "       <h2 style=\"font-size: 2rem; color: #A8192E;\" >Thank you for supporting " + merchant + "!</h2>" +
        "       <div id='giftCardContainer' style=\"z-index: 5; position: relative;\">" +
        
        "        <table align=\"center\" style=\"width:100%; border-collapse: collapse; margin: 0; padding: 0; border: none;\">" +
        "          <tr align=\"center\" style=\"height: 175px; background-color: #A8192E;\">" +
        "            <td background='cid:gift_card_template.png' style=\"z-index: 5; height: 175px; padding: 1.75%; object-fit: cover; border-radius: 15px; margin-bottom: 25px;\">" +
        "              <table>" + 
        "                 <tr align=\"center\">" +
        "                   <td style=\"color: #FFFFFF; font-size: 1.5rem; font-weight: bold;\">You made a donation of</td>" +
        "                 </tr>" +
        "                 <tr align=\"center\">" +
        "                   <td style=\"color: #F6B917; font-weight: bold; font-size: 1.85rem; margin-top: 1%;\">$" + amount_string + "</td>" +
        "                 </tr>" +
        "              </table>" +
        "            </td>" +
        "          </tr>" +

        "         <tr align=\"center\">" + 
        "           <td style=\"font-size: 1rem; padding-top: 35px;\">We'll let you know when " + merchant + " receives your donation.</td>" +
        "         </tr>" +
        "         <tr align=\"center\">" + 
        "           <td style= \"font-size: 1rem; padding-top: 10px; padding-bottom: 45px;\">Thank you for sending Chinatown love!</td>" +
        "         </tr>" +
        
        "         <tr align=\"center\">" +
        "           <table>" +
        "             <tr style=\"position: relative;\">" +
        "               <td><img src='cid:logo.png' style=\"width: 35%; float: left;\"/></td>" +
        "               <td style=\"float: right; max-width: 100px; v-align: bottom;\">" +
        "                 <table>" +
        "                   <tr>" +
        "                     <td>" +
        "                       <base href=\"hello@sendchinatownlove.com\" target=\"_blank\" style=\"v-align: bottom; text-decoration: none; padding: 95% 5% 0%;\">" +
        "                         <img src='cid:email-logo.png' style=\"width: 100%; height: auto;\"/>" +
        "                       </base>" +
        "                     </td>" +
        "                     <td>" +
        "                       <base href=\"https://www.instagram.com/sendchinatownlove/\" target=\"_blank\" style=\"text-decoration: none; padding: 90% 5% 0%;\">" +
        "                         <img src='cid:instagram-logo.png' style=\"width: 100%; height: auto;\"/>" +
        "                       </base>" +
        "                     </td>" +
        "                     <td>" +
        "                       <base href=\"https://www.facebook.com/sendchinatownlove/\" target=\"_blank\" style=\"text-decoration: none; padding: 90% 5% 0%;\">" +
        "                         <img src='cid:facebook-logo_360.png' style=\"width: 100%; height: auto;\"/>" +
        "                       </base>" +
        "                     </td>" +
        "                   </tr>" +
        "                 </table>" +
        "               </td>" +

        "              </tr>" +
        "           </table>" +
        "         </tr>" +
        "        </table>" +
        "   </div>" +
        "  </div>" +
        " </body>" +
        "</html>";

        RestClient.post api_url,
                        :from => "receipts@sendchinatownlove.com",
                        :to => "athena.chen@baruchmail.cuny.edu",
                        :subject => "testd email from Send Chinatown Love",
                        :html => html,
                        :inline => [get_file("facebook-logo_360.png"), get_file("gift_card_template.png"), get_file("instagram-logo.png"),
                                    get_file("logo.png"), get_file("mailer_header.png"), get_file("email-logo.png")]
    #
    # if request.env['HTTP_STRIPE_SIGNATURE'].present?
    #   handle_stripe_event
    # elsif request.env['HTTP_X_SQUARE_SIGNATURE'].present?
    #   handle_square_event
    # end
    #
    # json_response({})
  end

  private

  def get_file(file)
      File.new(File.join("app", "assets", "images", file))
  end

  def handle_stripe_event
    Stripe.api_key = ENV['STRIPE_API_KEY']

    # Verify webhook signature and extract the event
    # See https://stripe.com/docs/webhooks/signatures for more information.
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_KEY']
    payload = request.body.read

    event = Stripe::Webhook.construct_event(
      payload, sig_header, endpoint_secret
    )
    # Handle the payment_intent.succeeded event
    if event['type'] == 'payment_intent.succeeded'
      payment_intent = event['data']['object']

      # Fulfill the purchase
      handle_payment_intent_succeeded(stripe_payment_id: payment_intent['id'])
    end
  end

  def handle_square_event
    # Get the JSON body and HMAC-SHA1 signature of the incoming POST request
    callback_signature = request.env['HTTP_X_SQUARE_SIGNATURE']
    callback_body = request.body.string

    # Validate the signature
    unless valid_square_callback?(callback_body, callback_signature)
      # Fail if the signature is invalid
      raise InvalidSquareSignature, 'Invalid Signature Header from Square'
    end

    # Load the JSON body into a hash
    callback_body_json = JSON.parse(callback_body)

    # If the notification indicates a PAYMENT_UPDATED event...
    case callback_body_json['type']
    when 'payment.updated'
      payment = callback_body_json['data']['object']['payment']
      if payment['status'] == 'COMPLETED'
        # Fulfill the purchase
        handle_payment_intent_succeeded(
          square_payment_id: payment['id'],
          square_location_id: payment['location_id']
        )
      end
    when 'refund.created'
      refund = callback_body_json['data']['object']['refund']

      payment_intent = PaymentIntent.find_by(
        square_payment_id: refund['payment_id']
      )

      Refund.create!(
        square_refund_id: refund['id'],
        status: refund['status'],
        payment_intent: payment_intent
      )
    when 'refund.updated'
      square_refund = callback_body_json['data']['object']['refund']
      status = square_refund['status']

      refund = Refund.find_by(square_refund_id: square_refund['id'])
      refund.update(status: status)

      case status
      when 'COMPLETED'
        # Wrapped in a transaction so that if any one of them fail, none of the
        # Items are updated
        ActiveRecord::Base.transaction do
          refund.payment_intent.items.each do |item|
            item.update!(refunded: true)
          end
        end
      end
    end
  end

  # Validates HMAC-SHA1 signatures included in webhook notifications to ensure
  # notifications came from Square
  def valid_square_callback?(callback_body, callback_signature)
    # Combine your webhook notification URL and the JSON body of the incoming
    # request into a single string
    string_to_sign = 'https://api.sendchinatownlove.com/webhooks' +
                     callback_body

    # Generate the HMAC-SHA1 signature of the string, signed with your webhook
    # signature key
    string_signature = Base64.strict_encode64(
      OpenSSL::HMAC.digest(
        'sha1',
        ENV['SQUARE_WEBHOOK_SIGNATURE_KEY'],
        string_to_sign
      )
    )

    # Hash the signatures a second time (to protect against timing attacks)
    # and compare them
    Digest::SHA1.base64digest(string_signature) == Digest::SHA1.base64digest(
      callback_signature
    )
  end

  def handle_payment_intent_succeeded(
    square_payment_id: nil,
    square_location_id: nil,
    stripe_payment_id: nil
  )
    payment_intent = if square_payment_id.present?
                       PaymentIntent.find_by(
                         square_payment_id: square_payment_id,
                         square_location_id: square_location_id
                       )
                     else
                       PaymentIntent.find_by(stripe_id: stripe_payment_id)
                     end

    # TODO(jtmckibb): Each payment has an associated FSM. If we see the start
    #                 of a payment, we should expect for it to be completed.
    #                 If it isn't, then we should record it. Similarly with
    #                 refunds.

    # TODO(jtmckibb): If Square notifies us of a payment completion, or refund
    #                 and for some reason we fail in the middle of reacting to
    #                 that event, we want to be able to save the place that we
    #                 failed at and whenever Square tries to notify us again,
    #                 finish where we left off.

    # If the payment has already been processed
    if payment_intent.successful
      # rubocop:disable Layout/LineLength
      raise(
        DuplicatePaymentCompletedError,
        "This payment has already been received as COMPLETE payment_intent.id: #{payment_intent.id}"
      )
      # rubocop:enable Layout/LineLength
    end

    items = JSON.parse(payment_intent.line_items)
    items.each do |item|
      # TODO(jtmckibb): Add some tracking that tracks if it breaks somewhere
      # here

      amount = item['amount']
      seller_id = item['seller_id']
      merchant_name = Seller.find_by(seller_id: seller_id).name
      case item['item_type']
      when 'donation'
        email = payment_intent.email
        item = create_item(
          item_type: :donation,
          seller_id: seller_id,
          email: email,
          payment_intent: payment_intent
        )
        create_donation(item: item, amount: amount)
        begin
            send_donation_receipt(
              payment_intent: payment_intent,
              amount: amount,
              merchant: merchant_name)
        rescue
        end
      when 'gift_card'
        email = payment_intent.email
        item = create_item(
          item_type: :gift_card,
          seller_id: seller_id,
          email: email,
          payment_intent: payment_intent
        )

        gift_card_detail = create_gift_card(
          item: item,
          amount: amount,
          seller_id: seller_id
        )
        begin
            send_gift_card_receipt(
              payment_intent: payment_intent,
              amount: amount,
              merchant: merchant_name,
              receipt_id: gift_card_detail.seller_gift_card_id)
        rescue
        end
      else
        raise(
          InvalidLineItem,
          'Unsupported ItemType. Please verify the line_item.name.'
        )
      end
    end

    # Mark the payment as successful once we've recorded each object purchased
    # in our DB eg) Donation, Gift Card, etc.
    payment_intent.successful = true
    payment_intent.save
  end

  def create_donation(item:, amount:)
    DonationDetail.create!(
      item: item,
      amount: amount
    )
  end

  def create_gift_card(item:, amount:, seller_id:)
    gift_card_detail = GiftCardDetail.create!(
      expiration: Date.today + 1.year,
      item: item,
      gift_card_id: generate_gift_card_id,
      seller_gift_card_id: generate_seller_gift_card_id(seller_id: seller_id)
    )
    GiftCardAmount.create!(value: amount, gift_card_detail: gift_card_detail)
    gift_card_detail
  end

  def create_item(item_type:, seller_id:, email:, payment_intent:)
    seller = Seller.find_by(seller_id: seller_id)
    Item.create!(
      seller: seller,
      email: email,
      item_type: item_type,
      payment_intent: payment_intent
    )
  end

  def generate_gift_card_id
    (1..50).each do |_i|
      potential_id = SecureRandom.uuid
      # Use this ID if it's not already taken
      unless GiftCardDetail.where(gift_card_id: potential_id).present?
        return potential_id
      end
    end
    raise CannotGenerateUniqueHash, 'Error generating unique gift_card_id'
  end

  def generate_seller_gift_card_id(seller_id:)
    (1..50).each do |_i|
      hash = SecureRandom.hex.upcase
      potential_id_prefix = hash[0...3]
      potential_id_suffix = hash[3...5]
      potential_id = "##{potential_id_prefix}-#{potential_id_suffix}"
      # Use this ID if it's not already taken
      return potential_id unless GiftCardDetail.where(
        seller_gift_card_id: potential_id
      ).joins(:item).where(items: { seller_id: seller_id }).present?
    end
    raise CannotGenerateUniqueHash, 'Error generating unique gift_card_id'
  end

  def send_donation_receipt(payment_intent:, amount:, merchant:)
    amount_string = '%.2f' % ((amount.to_f)/100)
    html = "<!DOCTYPE html>" +
        "<html>" +
        "<head>" +
        "  <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />" +
        "</head>" +
        "<body>" +
        "<h1>Thank you for your donation to " + merchant + "!</h1>" +
        "<p> Donation amount: <b>$" + amount_string + "</b></p>" +
        "<p> Square receipt: " + payment_intent.receipt_url + "</p>" +
        "<p> We'll be in touch when " + merchant + " opens back up. Sending " +
        "  thanks from us and from Chinatown for your support! </p>" +
        "<p> Love,<p>" +
        "<p> the Send Chinatown Love team</p>" +
        "</body>" +
        "</html>"
    send_receipt(to: payment_intent.email, html: html)
  end

  def send_gift_card_receipt(payment_intent:, amount:, merchant:, receipt_id:)
    amount_string = '%.2f' % ((amount.to_f)/100)
    html = "<!DOCTYPE html>" +
        "<html>" +
        "<head>" +
        "  <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />" +
        "</head>" +
        "<body>" +
        "<h1>Thank you for your purchase from " + merchant + "!</h1>" +
        "<img src='cid:gift_card_template.png' style='height: 35vw; width: 100%; object-fit: cover; border-radius: 15px; margin-bottom: 25px;'/>"
        "<p> Gift card code: <b>" + receipt_id + "</b></p>" +
        "<p> Gift card balance: <b>$" + amount_string + "</b></p>" +
        "<p> Square receipt: " + payment_intent.receipt_url + "</p>" +
        "<p> We'll be in touch when " + merchant + " opens back up with details" +
        "  on how to use your gift card. Sending thanks from us and from Chinatown for" +
        "  your support! </p>" +
        "<p> Love,<p>" +
        "<p> the Send Chinatown Love team</p>" +
        "</body>" +
        "</html>"
    send_receipt(to: payment_intent.email, html: html)
  end

  def send_receipt(to:, html:)
  end
end
