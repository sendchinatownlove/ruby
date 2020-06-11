# frozen_string_literal: true

require 'optparse'

desc 'Seed gift cards for gift a meal program'
task create_gift_cards: :environment do
  options = {}
  optparse = OptionParser.new do |opts|
    opts.banner = 'Usage: rake add [options]'
    opts.on('-s', '--seller_id ARG', String, 'seller_id_id to associate the purchaser') { |seller_id| options[:seller_id] = seller_id }
    opts.on('-m', '--mail ARG', String, 'Email to associate the purchaser and recipient') { |email| options[:email] = email }
    opts.on('-q', '--quantity ARG', Integer, 'Quantity of gift_cards to generate') { |quantity| options[:quantity] = quantity }
    opts.on('-a', '--amount ARG', Integer, 'Amount on each gift card') { |amount| options[:amount] = amount }
  end

  begin
    optparse.parse!
    mandatory = %i[seller_id email quantity amount]
    missing = mandatory.select { |param| options[param].nil? }
    unless missing.empty?
      raise OptionParser::MissingArgument, missing.join(', ')
    end
  rescue OptionParser::InvalidOption, OptionParser::MissingArgument
    puts $ERROR_INFO.to_s
    puts optparse
    exit
  end

  seller_id = options[:seller_id]
  email = options[:email]
  quantity = options[:quantity]
  amount = options[:amount]

  seller = Seller.find_by!(seller_id: seller_id)
  contact = Contact.find_by!(email: email)

  ActiveRecord::Base.transaction do
    quantity.times do
      item = Item.create!(
        seller: seller,
        purchaser: contact,
        item_type: :gift_card
      )
      gift_card_detail = GiftCardDetail.create!(
        expiration: Date.today + 1.year,
        item: item,
        gift_card_id: GiftCardIdGenerator.generate_gift_card_id,
        seller_gift_card_id: GiftCardIdGenerator.generate_seller_gift_card_id(seller_id: seller_id),
        recipient: contact,
        single_use: true
      )
      GiftCardAmount.create!(value: amount, gift_card_detail: gift_card_detail)
    end
  end

  puts "Successfully created gift cards with args : #{options.inspect}"
  exit
end
