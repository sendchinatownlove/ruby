# frozen_string_literal: true

namespace :emailer do
  desc 'email task runner'
  task vouchers_to_merchants: :environment do
    desc 'sends all voucher codes to all of their merchants'

    ActiveRecord::Base.logger = Logger.new(STDOUT)

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
          order by gift_card_Detail_id, created_at desc
          ) as gca on gca.gift_card_detail_id = gcd.id 
        join items i on gcd.item_id = i.id
        join contacts c_r on gcd.recipient_id = c_r.id 
        where gcd.created_at > current_date - 30
        and i.refunded = FALSE
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
      r1 = GiftCardDetail.connection.select_all(gc_sql + seller.id.to_s)

      r2 = GiftCardDetail
            .select(:gift_card_id, :value, :email, :name, :created_at, :expiration)
            .joins(:item, :recipient)
            .where(items: {
              seller_id: seller.id,
              refunded: false
            })
            .joins("join (#{GiftCardAmount.latest_amounts_sql}) as la on la.gift_card_detail_id = gift_card_details.id")

      r3 = GiftCardDetail.connection.select_all(r2.to_sql)

      rn = [r1, r3]

      count = 1
      rn.each do |r|
        puts '----------' #r
        puts "looking at r#{count}"
        count += 1
        puts r
        puts r.inspect
        
  
        html += '<style> table, tr, td {border: 1px solid black}</style>'
        html += '<table><tr>'
  
        col_s = '' #r
    
        r.columns.each do |col|
          col_s += col.to_s + "\t" #r
          html += '<th>' + col + '</th>'
        end
  
        puts col_s #r
    
        html += '</tr>'
    
        r.each do |a|
          html += '<tr>'
          r_s = '' #r
          a.each do |key, val|
            if key == 'value' then
              val = '$' + (val / 100).to_s
            end
            if key === 'gift_card_id' then
              val = val[0...10]
            end
            r_s += val.to_s + "\t" #r
            html += '<td>' + val.to_s + '</td>'
          end
          puts r_s #r
          html += '</tr>'
        end
  
        puts '----------' #r

      end

  
      # html += '</table>'

      # puts(html)

      # puts('sending... to ' + seller.distributor.email)
      # # EmailManager::Sender.send_receipt(to: ENV['EMAIL_ADDRESS'], html: html)
      # puts('sent?')

    end
  end
end
