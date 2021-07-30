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
   
    curr_email = query[0]['email']
    curr_name = query[0]['name']

    email_template_header = '<html><style> table {border: 1px solid black}</style>'\
                            "Dear #{curr_name},<br />"\
                            '<p>Thank you for Sending Chinatown Love by supporting our merchants. '\
                            'We hope you have been able to visit one of NYC\' Chinatowns since the city\'s reopening. '\
                            'We are retiring out voucher program by <strong>September 1st, 2021.</strong></p>'\
                            '<p>Since our founding in March 2020, we\'ve raised over a million dollars in donations '\
                            'and vouchers, which helped <strong>32 merchants</strong> through the darker days of COVID-19! '\
                            'With that said, we are deciding to retire our voucher program '\
                            'so that we can focus on other programs such as Gift-A-Meal (GAM) and Business Development.</p>'\
                            '<a href="https://merchant.sendchinatownlove.com/gift-a-meal-home" target="_blank">Gift-a-Meal</a> '\
                            'is a program where we work with our merchants and community partners to provide '\
                            'meals and supplies to Chinatown citizens. '\
                            '<a href="https://www.instagram.com/p/CPSL2WlHhN9/" target="_blank">So far, '\
                            'we\'ve provided over 240,000 meals so far to New Yorkers in need.</a></p>'\
                            '<p>Business Development is where we provide pro-bono services to our merchants to '\
                            'help their small businesses grow.</p>'\
                            '<p>Any non-redeemed vouchers by September 1st, 2021 <strong>will be converted to '\
                            'a direct donation to the merchant</strong> and <strong>no action needs to be taken on your part.</strong> '\
                            'Your contribution with help Send Chinatown Love continue to provide aid and support to the community. '\
                            'If you have any questions about how to use your voucher please reply to this email and we will be able to help.</p>'\
                            '<table><tr><th>Merchant</th><th>Amount Remaining</th><th>Link</th></tr>'

    curr_table = email_template_header.dup

    query.each do |row|
      if curr_email == row['email']
        curr_table += "<tr><td>#{row['seller_name']}</td><td>#{'$' + (row['value'] / 100).to_s }</td><td><a href='#{row['redeem_url']}' target='_blank'>Redeem Voucher</a></td></tr>"  
      else 
        curr_table += '</table><p>Send Chinatown Love</p></html>'

        Rails.logger.info("Sending notification for #{curr_name} to #{curr_email} for unused voucher balances.")
        EmailManager::Sender.send_receipt(to: curr_email, html: curr_table, subject: 'Retiring Vouchers Program', from: 'support@sendchinatownlove.com')

        curr_name = row['name']
        curr_email = row['email']
        curr_table = email_template_header.dup
      end
    end
  end
end
