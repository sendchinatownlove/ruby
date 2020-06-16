# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command (or created
# alongside the database with db:setup).
[
  {
    seller_id: 'shunfa-bakery',
    cuisine_name: 'Bakery',
    name: 'Shunfa Bakery',
    story: "In the words of the owner Ping, “When Shunfa Bakery, a Chinese bakery in Brooklyn’s Chinatown, first opened in 2015, it was the result of the long journey of immigrants who worked hard to make a living on their own. It is the story of reclaiming one’s own path and taking charge—being one’s own boss after years of working long, back-breaking hours in various service jobs just to support themselves and their families.\n\nShunfa Bakery opened as a family establishment, and remains one to this day. Family was, and is still, the driver and key motivator in building this bakery from the ground up: family in the sense of children and parents, but also, family in the sense of the community. Shunfa Bakery has earned its place in Brooklyn’s nimble but strong Chinatown, serving Chinese comfort food, and hopes to continue to stay strong not just for business, but for our family.”",
    accept_donations: true,
    sell_gift_cards: true,
    owner_name: 'Shunfa Bakery',
    owner_image_url: 'assets/shunfa-bakery-logo.png',
    target_amount: 1_000_000,
    summary: nil,
    hero_image_url: 'assets/shunfa-bakery-hero.png',
    progress_bar_color: nil,
    business_type: 'Family-owned',
    num_employees: 3,
    founded_year: 2013,
    website_url: nil,
    menu_url: nil,
    square_location_id: 'E4R1NCMHG7B2Y'
  },
  {
    seller_id: '46-mott',
    cuisine_name: 'Bakery',
    name: '46 Mott',
    story: "Patrick is awesome, tbh",
    accept_donations: true,
    sell_gift_cards: true,
    owner_name: 'Patrick Mock',
    owner_image_url: 'assets/46-mott-logo.png',
    target_amount: 1_000_000,
    summary: nil,
    hero_image_url: 'assets/46-mott-hero.png',
    progress_bar_color: nil,
    business_type: nil,
    num_employees: 4,
    founded_year: 2018,
    website_url: nil,
    menu_url: nil,
    square_location_id: 'E4R1NCMHG7B2Z',
    non_profit_location_id: 'SDAFADS34334',
    cost_per_meal: 500
  },
  {
    seller_id: 'send-chinatown-love',
    accept_donations: false,
    sell_gift_cards: false,
    founded_year: 2020,
    square_location_id: ENV['POOL_SQUARE_LOCATION_ID']
  }
].each do |attributes|
  Seller.find_or_initialize_by(seller_id: attributes[:seller_id]).update!(attributes)
end

[
  {
    email: 'testytesterson@gmail.com',
    item_type: Item.donation,
    refunded: false,
    amount: 2000
  },
  {
    email: 'testytesterson2@gmail.com',
    item_type: Item.donation,
    refunded: false,
    amount: 1000
  },
  {
    email: 'testytesterson3@gmail.com',
    item_type: Item.donation,
    refunded: true,
    amount: 40_000
  }
].each do |attributes|
  seller = Seller.find_by(seller_id: 'shunfa-bakery')
  contact = Contact.find_or_create_by!(email: attributes[:email])
  payment_intent = PaymentIntent.create!(purchaser: contact, recipient: contact, square_location_id: seller.square_location_id, square_payment_id: Faker::Alphanumeric.alpha(number: 64))
  item = Item.create!(purchaser: contact, item_type: attributes[:item_type], refunded: attributes[:refunded], seller_id: seller.id, payment_intent_id: payment_intent.id)
  DonationDetail.create!(item_id: item.id, amount: attributes[:amount])
end

[
  {
    email: 'testytesterson@gmail.com',
    item_type: Item.gift_card,
    refunded: false,
    amounts: [10_000, 8000]
  },
  {
    email: 'testytesterson2@gmail.com',
    item_type: Item.gift_card,
    refunded: true,
    amounts: [7500, 3000]
  },
  {
    email: 'testytesterson3@gmail.com',
    item_type: Item.gift_card,
    refunded: false,
    amounts: [5000]
  }
].each do |attributes|
  seller = Seller.find_by(seller_id: 'shunfa-bakery')
  contact = Contact.find_or_create_by!(email: attributes[:email])
  payment_intent = PaymentIntent.create!(recipient: contact, purchaser: contact, square_location_id: seller.square_location_id, square_payment_id: Faker::Alphanumeric.alpha(number: 64))
  item = Item.create!(purchaser: contact, item_type: attributes[:item_type], refunded: attributes[:refunded], seller_id: seller.id, payment_intent_id: payment_intent.id)
  gift_card_detail = GiftCardDetail.create!(recipient: contact, item_id: item.id, gift_card_id: Faker::Alphanumeric.alpha(number: 64), seller_gift_card_id: Faker::Alphanumeric.alpha(number: 64))
  attributes[:amounts].each_with_index do |amount, i|
    GiftCardAmount.create!(gift_card_detail_id: gift_card_detail.id, value: amount, updated_at: Time.now + i.days)
  end
end
