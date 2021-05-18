# frozen_string_literal: true
require_relative '../../app/helpers/unused_cards_sql.rb'
namespace :emailer do
  desc 'email task runner'
  task :vouchers_to_merchant, %i[seller_id email time_range] => [:environment] do |_task, args|
    desc 'Sends voucher codes for a merchant to a specified email for a time range (default 1 year)'

    range = 1.year.ago
    case args.time_range
    when 'month'
      range = 1.month.ago
    when 'two months'
      range = 2.months.ago
    when 'week'
      range = 1.week.ago
    when 'two weeks'
      range = 2.weeks.ago
    when 'three weeks'
      range = 3.weeks.ago
    end

    seller = Seller.find_by(seller_id: args.seller_id)

    unless args.email.present? && seller.present?
      Rails.logger.error('Missing information, either seller not found or no email provided, no email sent')
      return
    end

    Rails.logger.info('Getting gift cards for ' + seller.seller_id)
    html = '' # start building html with an empty string

    seller_name = seller.seller_id.gsub('-', ' ').titlecase
    html += "<h3>Hello #{seller_name}!</h3>"
    html += '<p>Here are your recent voucher purchases</p>'

    # query for all gift cards info for that seller
    query = GiftCardDetail
            .select(:seller_gift_card_id, :value, :single_use, :name, :email, :created_at, :expiration)
            .joins(:item, :recipient)
            .where(items: {
                     seller_id: seller.id,
                     refunded: false
                   },
                   created_at: range...)
            .joins("join (#{GiftCardAmount.latest_amounts_sql}) as la on la.gift_card_detail_id = gift_card_details.id")
            .order(:seller_gift_card_id)
            .to_sql

    # processing in one query to get a PG::Result, instead multiple queries when building html
    r = GiftCardDetail.connection.select_all(query)

    html += '<style> table {border: 1px solid black}</style>'\
            '<table><tr>'

    r.columns.each do |col|
      col = 'Code' if col == 'seller_gift_card_id'
      col = col.gsub '_', ' '
      html += '<th>' + col + '</th>'
    end

    html += '</tr>'

    r.each do |a|
      html += '<tr>'
      a.each do |key, val|
        # quick formatting
        if key == 'created_at' || key == 'expiration' && val.present?
          val = val.to_formatted_s(:short)
        end
        val = '$' + (val / 100).to_s if key == 'value'
        val = val ? 'Y' : 'N' if key == 'single_use'
        val = 'N/A' if val.blank?
        html += '<td>' + val.to_s + '</td>'
      end
      html += '</tr>'
    end

    html += '</table>'\
            '<p>For questions about how Send Chinatown Love vouchers work, '\
            'please feel free to reply to this email!</p>'\
            '<p>All the best from the team at Send Chinatown Love</p>'

    Rails.logger.info("Sending #{r.rows.length} vouchers for #{seller_name} to #{args.email} from the last #{args.time_range}")
    EmailManager::Sender.send_receipt(to: args.email, html: html)
  end

  task :unused_voucher_to_customer => [:environment] do |_task, args|
    desc 'Resend unused vouchers to customers'
   
    # query for all gift cards info for that seller
    query = ActiveRecord::Base.connection.execute($unused_vouchers_sql_query)
   # puts query.to_json

    curr_email = query[0]['email']
    curr_table = '<html><style> table {border: 1px solid black}</style>'
    curr_table += "<h3>Hello #{query[0]['name']}!</h3><table>"
    
    query.each do |row|
      if curr_email == row['email']
        curr_table += "<tr><td>#{row['seller_name']}</td><td>#{'$' + (row['value'] / 100).to_s }</td><td><a href='#{row['redeem_url']}' target='_blank'>Redeem Voucher</a></td></tr>"  
      else 
        curr_email = row['email']
        curr_table += '</table></html>'
        puts curr_table
        curr_table = '<html><style> table {border: 1px solid black}</style><table>'
      end
    end
=begin

html = '' # start building html with an empty string
        #html += "<h3>Hello #{seller_name}!</h3>"
        #html += '<p>Here are your recent voucher purchases</p>'
    
    html += '<style> table {border: 1px solid black}</style>'\
            '<table><tr>'

    r.columns.each do |col|
      col = 'Code' if col == 'seller_gift_card_id'
      col = col.gsub '_', ' '
      html += '<th>' + col + '</th>'
    end

    html += '</tr>'

    r.each do |a|
      html += '<tr>'
      a.each do |key, val|
        # quick formatting
        if key == 'created_at' || key == 'expiration' && val.present?
          val = val.to_formatted_s(:short)
        end
        val = '$' + (val / 100).to_s if key == 'value'
        val = val ? 'Y' : 'N' if key == 'single_use'
        val = 'N/A' if val.blank?
        html += '<td>' + val.to_s + '</td>'
      end
      html += '</tr>'
    end

    html += '</table>'\
            '<p>For questions about how Send Chinatown Love vouchers work, '\
            'please feel free to reply to this email!</p>'\
            '<p>All the best from the team at Send Chinatown Love</p>'

    Rails.logger.info("Sending #{r.rows.length} vouchers for #{seller_name} to #{args.email} from the last #{args.time_range}")
    EmailManager::Sender.send_receipt(to: args.email, html: html)
=end
  end
=begin
  task :unused_voucher_to_customer, %i[single_use] => [:environment] do |_task, args|
    desc 'Resend unused vouchers to customers (default not single use)'

    single_use = args.has_key?(:single_use) ? !!args.single_use : false

    html = '' # start building html with an empty string

    seller_name = seller.seller_id.gsub('-', ' ').titlecase
    html += "<h3>Hello #{seller_name}!</h3>"
    html += '<p>Here are your recent voucher purchases</p>'

    # query for all gift cards info for that seller
    query = GiftCardDetail
            .select(:seller_gift_card_id, :value, :single_use, :name, :email, :created_at, :expiration)
            .joins(:item, :recipient)
            .where(items: {
                     seller_id: seller.id,
                     refunded: false
                   },
                   created_at: range...)
            .joins("join (#{GiftCardAmount.latest_amounts_sql}) as la on la.gift_card_detail_id = gift_card_details.id")
            .order(:seller_gift_card_id)
            .to_sql

    # processing in one query to get a PG::Result, instead multiple queries when building html
    r = GiftCardDetail.connection.select_all(query)

    html += '<style> table {border: 1px solid black}</style>'\
            '<table><tr>'

    r.columns.each do |col|
      col = 'Code' if col == 'seller_gift_card_id'
      col = col.gsub '_', ' '
      html += '<th>' + col + '</th>'
    end

    html += '</tr>'

    r.each do |a|
      html += '<tr>'
      a.each do |key, val|
        # quick formatting
        if key == 'created_at' || key == 'expiration' && val.present?
          val = val.to_formatted_s(:short)
        end
        val = '$' + (val / 100).to_s if key == 'value'
        val = val ? 'Y' : 'N' if key == 'single_use'
        val = 'N/A' if val.blank?
        html += '<td>' + val.to_s + '</td>'
      end
      html += '</tr>'
    end

    html += '</table>'\
            '<p>For questions about how Send Chinatown Love vouchers work, '\
            'please feel free to reply to this email!</p>'\
            '<p>All the best from the team at Send Chinatown Love</p>'

    Rails.logger.info("Sending #{r.rows.length} vouchers for #{seller_name} to #{args.email} from the last #{args.time_range}")
    EmailManager::Sender.send_receipt(to: args.email, html: html)
  end
=end
end
