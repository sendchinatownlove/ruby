# frozen_string_literal: true

module SellersHelper
  def self.generate_seller_json(seller:)
    if seller.locations.size > 1
      Rails.logger.info "Seller location has #{seller.locations.size} locations"
    end

    location = seller.locations.first
    locations = seller.locations #field is deprecated
    distributor = seller.distributor
    json = seller.as_json
    json['distributor'] = distributor.as_json unless distributor.nil?
    json['location'] = location.as_json
    json['locations'] = locations.as_json #field is deprecated

    json['donation_amount'] = seller.donation_amount
    json['gift_card_amount'] = seller.gift_card_amount
    json['amount_raised'] = json['donation_amount'] + json['gift_card_amount']

    json['num_gift_cards'] = seller.num_gift_cards
    json['num_donations'] = seller.num_donations
    json['num_contributions'] = json['num_gift_cards'] + json['num_donations']

    json
  end
end
