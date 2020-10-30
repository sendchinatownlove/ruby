# frozen_string_literal: true

# Convert lanzhou's donations to gift cards
#
# This was done when we found out that 88 Lanzhou was closing,
# we wanted to switch to a gift-a-meal campaign for them,
# and move all of our donations into GAM gift cards to kickstart the campaign.
#
# The new campaign was created through postman before running this

Item.transaction do
  eightyeightlanzhou = Seller.find_by(seller_id: '88-lanzhou')
  scl_contact = Contact.find(122)
  items = Item.where(seller: eightyeightlanzhou)
  campaign = Campaign.find(14)
  puts(items.length)
  items = items.select { |item| item.donation_detail.present? }
  puts(items.length)
  amount = items.map { |item| item.donation_detail.amount }.inject(0) { |sum, x| sum + x }
  cards_to_make = amount / campaign.price_per_meal
  count = 0
  items.each { |item| item.update!(refunded: true) }
  while amount > campaign.price_per_meal
    puts("creating gift card #{count} of #{cards_to_make}")
    item = Item.create!(
      seller: eightyeightlanzhou,
      item_type: 'gift_card',
      campaign_id: campaign.id,
      purchaser: scl_contact
    )
    gift_card_detail = GiftCardDetail.create!(
      recipient_id: campaign.distributor.contact_id,
      item_id: item.id,
      gift_card_id: GiftCardIdGenerator.generate_gift_card_id,
      seller_gift_card_id: GiftCardIdGenerator.generate_seller_gift_card_id(seller_id: '88-lanzhou'),
      single_use: true
    )
    GiftCardAmount.create!(
      gift_card_detail_id: gift_card_detail.id,
      value: campaign.price_per_meal
    )
    amount -= campaign.price_per_meal
    count += 1
  end
  puts("Total gift cards made: #{count}, remaining amount: #{amount}")
end

# -----

Item.transaction do
  eightyeightlanzhou = Seller.find_by(seller_id: '88-lanzhou')
  items = Item.where(seller: eightyeightlanzhou)

  campaign = Campaign.last
  puts(campaign)
  items = items.select { |item| item.donation_detail.present? }

  amount = items.map { |item| item.donation_detail.amount }.inject(0) { |sum, x| sum + x }
  puts(amount)
end

# ------

Item.transaction do
  eightyeightlanzhou = Seller.find_by(seller_id: '88-lanzhou')
  items = Item.where(seller: eightyeightlanzhou)
  items.each do |item|
    puts "item: #{item.id}" if item.donation_detail.blank?
  end
end
