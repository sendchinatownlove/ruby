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
    # See instructions for setting this up at
    # https://docs.google.com/document/d/1UPNCwjWS_T7XT5AXsewphu6NvNdV7TQLSJub-RBRAG0/edit
    square_location_id: ENV['SQUARE_LOCATION_ID']
  },
  {
    seller_id: '46-mott',
    cuisine_name: 'Bakery',
    name: '46 Mott',
    story: 'Patrick is awesome, tbh',
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
    square_location_id: 'E4R1NCMHG7B2Y',
    non_profit_location_id: '1VHM457EG87XX',
    cost_per_meal: 500
  },
  {
    seller_id: 'send-chinatown-love',
    accept_donations: false,
    sell_gift_cards: false,
    founded_year: 2020,
    # See instructions for setting this up at
    # https://docs.google.com/document/d/1UPNCwjWS_T7XT5AXsewphu6NvNdV7TQLSJub-RBRAG0/edit
    square_location_id: ENV['POOL_SQUARE_LOCATION_ID']
  }
].each do |attributes|
  Seller.find_or_initialize_by(seller_id: attributes[:seller_id]).update!(attributes)
end

[
  {
    seller_id: 1,
    open_time: '07:00:00AM',
    close_time: '06:00:00PM',
    open_day: 'MON',
    close_day: 'MON'
  },
  {
    seller_id: 1,
    open_time: '07:00:00AM',
    close_time: '12:30:00AM',
    open_day: 'TUE',
    close_day: 'WED'
  },
  {
    seller_id: 1,
    open_time: '07:00:00AM',
    close_time: '06:00:00PM',
    open_day: 'THU',
    close_day: 'THU'
  },
  {
    seller_id: 1,
    open_time: '07:00:00AM',
    close_time: '06:00:00PM',
    open_day: 'SUN',
    close_day: 'SUN'
  }
].each do |attributes|
  OpenHour.find_or_create_by(seller_id: attributes[:seller_id], open_day: attributes[:open_day]).update!(attributes)
end

[
  {
    id: 1,
    seller_id: 1,
    phone_number: '111-111-1111'
  },
  {
    id: 2,
    seller_id: 1,
    url: 'http://caviar.com/restaurant/'
  },
  {
    id: 3,
    seller_id: 1,
    url: 'http://doordash.com/menu/'
  },
  {
    id: 4,
    seller_id: 1,
    url: 'http://grubhub.com/restaurant/'
  },
  {
    id: 5,
    seller_id: 2,
    url: 'http://postmates.com/restaurant/'

  },
  {
    id: 6,
    seller_id: 2,
    url: 'http://seamless.com/menu/'
  },
  {
    id: 7,
    seller_id: 2,
    url: 'http://ubereats.com/new-york/food-delivery/'
  }
].each do |attributes|
  DeliveryOption.find_or_create_by(id: attributes[:id]).update!(attributes)
end

[
  {
    name: 'Phone',
    icon_url: './assets/Call@2x.png',
    delivery_option_id: 1
  },
  {
    name: 'Caviar',
    icon_url: './assets/Caviar@2x.png',
    delivery_option_id: 2
  },
  {
    name: 'DoorDash',
    icon_url: './assets/DoorDash@2x.png',
    delivery_option_id: 3
  },
  {
    name: 'Grubhub',
    icon_url: './assets/Grubhub@2x.png',
    delivery_option_id: 4
  },
  {
    name: 'Postmates',
    icon_url: './assets/Postmates@2x.png',
    delivery_option_id: 5
  },
  {
    name: 'Seamless',
    icon_url: './assets/Seamless@2x.png',
    delivery_option_id: 6
  },
  {
    name: 'UberEats',
    icon_url: './assets/UberEats@2x.png',
    delivery_option_id: 7
  }
].each do |attributes|
  deliveryOption = DeliveryOption.find_by(id: attributes[:delivery_option_id])
  DeliveryType.find_or_create_by(name: attributes[:name], delivery_option_id: deliveryOption.id).update!(attributes)
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
    amounts: [10_000, 8000],
    seller_id: 'shunfa-bakery',
    single_use: false
  },
  {
    email: 'testytesterson2@gmail.com',
    item_type: Item.gift_card,
    refunded: true,
    amounts: [7500, 3000],
    seller_id: 'shunfa-bakery',
    single_use: false
  },
  {
    email: 'testytesterson3@gmail.com',
    item_type: Item.gift_card,
    refunded: false,
    amounts: [5000],
    seller_id: 'shunfa-bakery',
    single_use: false
  },
  {
    email: 'testytesterson3@gmail.com',
    item_type: Item.gift_card,
    refunded: false,
    amounts: [2000],
    seller_id: '46-mott',
    single_use: false
  },
  {
    email: 'testytesterson4@gmail.com',
    item_type: Item.gift_card,
    refunded: false,
    amounts: [1000],
    seller_id: 'shunfa-bakery',
    single_use: true
  },
  {
    email: 'testytesterson4@gmail.com',
    item_type: Item.gift_card,
    refunded: false,
    amounts: [2500, 0],
    seller_id: 'shunfa-bakery',
    single_use: false
  },
  {
    email: 'testytesterson5@gmail.com',
    item_type: Item.gift_card,
    refunded: false,
    amounts: [1500, 0],
    seller_id: 'shunfa-bakery',
    single_use: false
  }
].each do |attributes|
  seller = Seller.find_by(seller_id: attributes[:seller_id])
  contact = Contact.find_or_create_by!(email: attributes[:email])
  payment_intent = PaymentIntent.create!(recipient: contact, purchaser: contact, square_location_id: seller.square_location_id, square_payment_id: Faker::Alphanumeric.alpha(number: 64))
  item = Item.create!(purchaser: contact, item_type: attributes[:item_type], refunded: attributes[:refunded], seller_id: seller.id, payment_intent_id: payment_intent.id)
  gift_card_detail = GiftCardDetail.create!(recipient: contact, item_id: item.id, gift_card_id: Faker::Alphanumeric.alpha(number: 64), seller_gift_card_id: '#' + Faker::Alphanumeric.alpha(number: 5).upcase.insert(3, '-'), single_use: attributes[:single_use])
  attributes[:amounts].each_with_index do |amount, i|
    GiftCardAmount.create!(gift_card_detail_id: gift_card_detail.id, value: amount, updated_at: Time.now + i.days)
  end
end

[
  {
    active: true,
    multiplier: 0.1,
    seller_id: '46-mott'
  },
  {
    active: true,
    multiplier: 0.1,
    seller_id: '46-mott'
  },
  {
    active: false,
    multiplier: 0.1,
    seller_id: 'shunfa-bakery'
  }
].each do |attributes|
  seller = Seller.find_by(seller_id: attributes[:seller_id])
  fee_attributes = attributes.except(:seller_id)
  fee_attributes[:seller_id] = seller.id
  Fee.create!(fee_attributes)
end

seller = Seller.find_by(seller_id: 'shunfa-bakery')
contact = Contact.find_or_create_by!(name: 'Apex for Youth', email: 'distributor@apexforyouth.com')
distributor = Distributor.create contact: contact, image_url: 'apexforyouth.com', website_url: 'apexforyouth.com', name: 'Apex for Youth'
location = Location.create(address1: '123 Mott St.', city: 'Zoo York', neighborhood: 'Chinatown', state: 'NY', zip_code: '12345')
Campaign.create(
  seller_id: seller.id,
  distributor: distributor,
  location: location,
  active: true,
  end_date: Time.now + 30.days
)

[
  {
    name: '46 Mott',
    seller_id: '2',
    stamp_url: 'http://example.com/placeholder.jpg'
  }
].each do |attributes|
  attributes[:tickets_secret] = Faker::Internet.uuid
  ParticipatingSeller.find_or_create_by!(name: attributes[:name]).update!(attributes)
end
[
  {
    name: "Boys Don't Cry",
    location_id: '2',
    logo_url: 'http://example.com/placeholder.jpg',
    reward: 'One free shot',
    reward_cost: 3
  }
].each do |attributes|
  SponsorSeller.find_or_create_by!(name: attributes[:name]).update!(attributes)
end

(0..6).each do |i|
  name = Faker::Name.name
  contact = i.odd? ? Contact.find_or_create_by!(email: Faker::Internet.email(name: name), name: name) : nil
  participant = ParticipatingSeller.find_by(seller_id: 2)
  sponsor = i.even? ? SponsorSeller.find_by(location_id: 2) : nil
  redeemed_at = i % 3 == 0 ? Time.now - i.days : nil

  Ticket.create!(
    contact: contact,
    participating_seller: participant,
    sponsor_seller: sponsor,
    redeemed_at: redeemed_at
  )
end
[
  {
    id: 1,
    open_time: '07:00:00',
    close_time: '18:00:00',
    open_day: 0,
    close_day: 0,
  },
  {
    id: 2,
    open_time: '07:00:00',
    close_time: '00:30:00',
    open_day: 1,
    close_day: 2,
  },
  {
    id: 3,
    open_time: '07:00:00',
    close_time: '18:00:00',
    open_day: 3,
    close_day: 3,
  },
  {
    id: 4,
    open_time: '07:00:00',
    close_time: '18:00:00',
    open_day: 6,
    close_day: 6,
  },
].each do |attributes|
  seller = Seller.find_by(seller_id: 'shunfa-bakery')
  updatedAttr = attributes
  updatedAttr[:seller_id] = seller[:id]
  OpenHour.find_or_create_by(id: attributes[:id]).update!(updatedAttr)
end

[
  {
    id: 1,
    phone_number: '111-111-1111',
    seller_id: 1,
    delivery_type: {
      id: 1,
      name: 'Phone',
      icon_url: './assets/Call@2x.png'
    }
  },
  {
    id: 2,
    url: 'http://caviar.com/restaurant/',
    seller_id: 1,
    delivery_type: {
      id: 2,
      name: 'Caviar',
      icon_url: './assets/Caviar@2x.png'
    }
  },
  {
    id: 3,
    url: 'http://doordash.com/menu/',
    seller_id: 1,
    delivery_type: {
      id: 3,
      name: 'DoorDash',
      icon_url: './assets/DoorDash@2x.png'
    }
  },
  {
    id: 4,
    url: 'http://grubhub.com/restaurant/',
    seller_id: 1,
    delivery_type: {
      id: 4,
      name: 'Grubhub',
      icon_url: './assets/Grubhub@2x.png'
    }
  },
  {
    id: 5,
    url: 'http://postmates.com/restaurant/',
    seller_id: 2,
    delivery_type: {
      id: 5,
      name: 'Postmates',
      icon_url: './assets/Postmates@2x.png'
    }
  },
  {
    id: 6,
    url: 'http://seamless.com/menu/',
    seller_id: 2,
    delivery_type: {
      id: 6,
      name: 'Seamless',
      icon_url: './assets/Seamless@2x.png'
    }
  },
  {
    id: 7,
    url: 'http://ubereats.com/new-york/food-delivery/',
    seller_id: 2,
    delivery_type: {
      id: 7,
      name: 'Uber Eats',
      icon_url: './assets/UberEats@2x.png'
    }
  },
].each do | attr |
  seller = Seller.find_by(id: attr[:seller_id])
  deliveryOptionAttr = attr.except(:delivery_type, :seller_id)
  delivTypeAttr = attr.fetch(:delivery_type)

  deliveryOption = DeliveryOption.find_or_create_by!(id: attr[:id], seller_id: seller[:id])
  deliveryOption.update!(deliveryOptionAttr)

  delivTypeAttr[:delivery_option_id] = deliveryOption[:id]
  DeliveryType.find_or_create_by!(id: delivTypeAttr[:id], delivery_option_id: delivTypeAttr[:delivery_option_id], name: delivTypeAttr[:name]).update(delivTypeAttr)
end
