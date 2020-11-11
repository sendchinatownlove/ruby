# frozen_string_literal: true

module SellersHelper
  def self.generate_seller_json(seller:)
    locations = seller.locations
    distributor = get_deprecated_distributor(seller: seller)

    # Do not return the secret token that gives access to all of their gift
    # cards
    json = seller.as_json.except('gift_cards_access_token')
    # NB(jmckibben): Deprecated field. Use /campaigns/ endpoint instead
    json['distributor'] = distributor.as_json unless distributor.nil?
    json['locations'] = locations.as_json

    # Currently does not take into account transaction fees
    json['cost_per_meal'] = seller.cost_per_meal

    json['donation_amount'] = seller.donation_amount
    json['gift_card_amount'] = seller.gift_card_amount
    json['amount_raised'] = json['donation_amount'] + json['gift_card_amount']

    json['num_gift_cards'] = seller.num_gift_cards
    json['num_donations'] = seller.num_donations
    json['num_contributions'] = json['num_gift_cards'] + json['num_donations']

    json
  end

  private

  def self.get_deprecated_distributor(seller:)
    # Get the last active campaign
    campaign = Campaign.find_by(
      seller_id: seller.id,
      active: true,
      valid: true
    )
    campaign.present? ? campaign.distributor.contact : nil
  end
end
