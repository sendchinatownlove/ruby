# frozen_string_literal: true

namespace :emailer do
  desc 'email task runner'
  task vouchers_to_merchants: :environment do
    desc 'sends all voucher codes to all of their merchants'
    # c = Contact.find_by(seller_id: 3)
    # puts(c.email)

    sql = 'select gcd.gift_card_id,
        gca.value,
        c_s.name as seller_name,
        c_s.email as seller_email,
        c_r.email as recipient_email,
        c_r.name as recipient_name,
        gcd.created_at,
        gcd.expiration
        from gift_card_details gcd
        join (
            select distinct on (gift_card_detail_id) *
            from gift_card_amounts
            ) as gca on gca.gift_card_detail_id = gcd.id
        join items i on gcd.item_id = i.id
        join contacts c_s on i.seller_id = c_s.seller_id
        join contacts c_r on gcd.recipient_id = c_r.id
        where gcd.created_at > current_date - 30'

    # records_array = ActiveRecord::Base.connection.execute(sql)
    # puts(records_array.inspect)

    r = GiftCardDetail.connection.select_all(sql)

    html = ''
    html += '<style> table, tr, td {border: 1px solid black}</style>'
    html += <table><tr>'

    r.columns.each do |col|
      html += '<th>' + col + '</th>'
    end

    html += '</tr>'

    r.each do |a|
      html += '<tr>'
      a.each do |_key, val|
        html += '<td>' + val.to_s + '</td>'
      end
      html += '</tr>'
    end

    html += '</table>'

    puts(html)

    puts('sending...')
    EmailManager::Sender.send_receipt(to: ENV['EMAIL_ADDRESS'], html: html)
    puts('sent?')
  end
end
