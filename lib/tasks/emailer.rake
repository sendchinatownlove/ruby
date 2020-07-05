# frozen_string_literal: true

namespace :emailer do
  desc 'email task runner'
  task vouchers_to_merchants: :environment do
    desc 'sends all voucher codes to all of their merchants'

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
      unless seller.distributor
        next
      end

      puts('getting gift cards for ' + seller.seller_id)
      html = '' # start building html with an empty string

      html += "<h3> Hello #{seller.distributor.name} at #{seller.seller_id} </h3>"
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

      puts('sending... to ' + seller.distributor.email)
      # EmailManager::Sender.send_receipt(to: ENV['EMAIL_ADDRESS'], html: html)
      puts('sent?')

    end
  end
end
