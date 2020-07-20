# frozen_string_literal: true

namespace :email_giftcards do
  desc 'Email customers the gift cards that they ordered'
  task :send_emails => :environment do
    desc 'send emails'

    unique_recipients = GiftCardDetail
                        .joins(:item, :recipient)
                        .where(items: { refunded: false })
                        .distinct.pluck(:recipient_id)

    unique_recipients.each do |id|
      html = '<!DOCTYPE html>' \
              '<html>' \
              '<head>' \
              "  <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />" \
              '</head>' \
              '<body>' \
              '<p> Thank you for supporting local chinatown businesses! As our merchants open up, you will be able to redeem the giftcards you have purchased below.</p>'
      recipient = Contact.find_by(id: id)
      gift_cards = GiftCardDetail.where(recipient_id: id).to_a
      html += '<style> table {border: 1px solid black}</style>'\
            '<table>'
      gift_cards.each do |gc|
        gift_card_url = 'merchant.sendchinatownlove.com/voucher/' + gc.gift_card_id
        amount_string = EmailManager::Sender.format_amount(amount: gc.amount)
        item = Item.find_by(id: gc.item_id)
        merchant_name = Seller.find_by(id: item.seller_id).name
        html += '<tr><p>View your <b>$' + amount_string + '</b> gift card for <b>' + merchant_name + '<a href="' + gift_card_url + '"> here</a></b></p></tr>'
      end
      html += '</table>'
      EmailManager::Sender.send_receipt(to: recipient.email, html: html)
    end
  end
end
