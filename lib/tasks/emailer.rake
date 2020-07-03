# frozen_string_literal: true

namespace :emailer do
  desc 'email task runner'
  task vouchers_to_merchants: :environment do
    desc 'sends all voucher codes to all of their merchants'

    s_sql = 'select c.email as seller_contact_email,
        c.name as seller_contact_name,
        s.seller_id as seller_name	   
        from contacts c 
        join sellers s on c.seller_id = s.id
        where s.id = '

    gc_sql = 'select gcd.gift_card_id, 
        gca.value,
        c_r.email as recipient_email,
        c_r.name as recipient_name,
        gcd.created_at,
        gcd.expiration 
        from gift_card_details gcd 
        join ( -- latest gift card amount for a gift card id
        select distinct on (gift_card_detail_id) *
        from gift_card_amounts
        ) as gca on gca.gift_card_detail_id = gcd.id 
        join items i on gcd.item_id = i.id
        join contacts c_r on gcd.recipient_id = c_r.id 
        where gcd.created_at > current_date - 30
        and i.seller_id = '

    Seller.all.each do |seller|
      puts('getting gift cards for ' + seller.seller_id)
      html = '' # start building html with an empty string

      # query for seller relevant info
      s = Seller.connection.select_all(s_sql + seller.id.to_s)
      s = s[0] # only one row returned

      html += "<h3> Hello #{s['seller_contact_name']} at #{seller.seller_id} </h3>"
      html += "<p>Here's last weeks vouchers:</p>"

      # query for all gift cards info for that seller
      r = GiftCardDetail.connection.select_all(gc_sql + seller.id.to_s)

      html += '<style> table, tr, td {border: 1px solid black}</style>'
      html += '<table><tr>'
  
      r.columns.each do |col|
        html += '<th>' + col + '</th>'
      end
  
      html += '</tr>'
  
      r.each do |a|
        html += '<tr>'
        a.each do |key, val|
          if key == 'value' then
            val = '$' + (val / 100).to_s
          end
          html += '<td>' + val.to_s + '</td>'
        end
        html += '</tr>'
      end
  
      html += '</table>'

      puts(html)

      puts('sending... to ' + s['seller_contact_email'])
      EmailManager::Sender.send_receipt(to: ENV['EMAIL_ADDRESS'], html: html)
      puts('sent?')

    end
  end
end
