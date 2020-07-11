# frozen_string_literal: true

namespace :emailer do
  desc 'email task runner'
  task vouchers_to_merchants: :environment do
    desc 'sends all voucher codes to all of their merchants'

    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger = Logger.new(STDOUT)

    Seller.all.each do |seller|
      unless seller.distributor
        Rails.logger.warn("No distributor found for #{seller.seller_id}, skipping email...")
        next
      end

      Rails.logger.info('Getting gift cards for ' + seller.seller_id)
      html = '' # start building html with an empty string

      html += "<h3> Hello #{seller.distributor.name} at #{seller.seller_id} </h3>"
      html += "<p>Here's last weeks vouchers:</p>"

      # query for all gift cards info for that seller
      query = GiftCardDetail
              .select(:gift_card_id, :value, :name, :email, :created_at, :expiration)
              .joins(:item, :recipient)
              .where(items: {
                seller_id: seller.id,
                refunded: false
              })
              .joins("join (#{GiftCardAmount.latest_amounts_sql}) as la on la.gift_card_detail_id = gift_card_details.id")
              .to_sql

      # processing in one query to get a PG::Result, instead multiple queries when building html
      r = GiftCardDetail.connection.select_all(query)
      
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
          if val.blank? then
            val = 'N/A'
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
