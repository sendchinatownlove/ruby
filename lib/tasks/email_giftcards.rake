# frozen_string_literal: true

namespace :emailer do
  desc 'Email customers the gift cards that they ordered'
  task :vouchers_to_customers => :environment do
    desc 'send emails'

    unique_recipients = GiftCardDetail
                        .where(single_use: false)
                        .joins(:item, :recipient)
                        .where(items: { refunded: false })
                        .distinct.pluck(:recipient_id)
    Rails.logger.info('Sending #{unique_recipients.length} emails')
    unique_recipients.each do |id|
      html = '<!DOCTYPE html>' \
              '<html>' \
              '<head>' \
              "  <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />" \
              '</head>' \
              '<body>' \
              '<p> Thank you for supporting local Chinatown businesses! You can access your gift card(s) below:</p>'
      recipient = Contact.find_by(id: id)
      Rails.logger.info('Sending gift cards for #{recipient.email}')
      gift_cards = GiftCardDetail.where(recipient_id: id).to_a
      html += '<style> table {border: 1px solid black}</style>'\
            '<table>'
      has_valid_giftcard = false
      gift_cards.each do |gc|
        if (gc.amount != 0)
          has_valid_giftcard = true
          gift_card_url = 'merchant.sendchinatownlove.com/voucher/' + gc.gift_card_id
          amount_string = EmailManager::Sender.format_amount(amount: gc.amount)
          item = Item.find_by(id: gc.item_id)
          merchant_name = Seller.find_by(id: item.seller_id).name
          html += '<tr><p>View your <b>$' + amount_string + '</b> gift card for <b>' + merchant_name + ' <a href="' + gift_card_url + '">here</a></b></p></tr>'
        end
      end
      html += '</table>'
      if has_valid_giftcard
        EmailManager::Sender.send_receipt_with_subject(to: recipient.email, html: html, subject: 'Your gift card(s) from Send Chinatown Love')
      end
    end
  end
end
