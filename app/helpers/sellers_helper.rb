# frozen_string_literal: true

module SellersHelper
  def self.generate_seller_json(seller:)
    locations = seller.locations
    distributor = seller.distributor
    json = seller.as_json
    json['distributor'] = distributor.as_json unless distributor.nil?
    json['locations'] = locations.as_json

    json['donation_amount'] = seller.donation_amount
    json['gift_card_amount'] = seller.gift_card_amount
    json['amount_raised'] = json['donation_amount'] + json['gift_card_amount']

    json['num_gift_cards'] = seller.num_gift_cards
    json['num_donations'] = seller.num_donations
    json['num_contributions'] = json['num_gift_cards'] + json['num_donations']

    json
  end
end
