# frozen_string_literal: true

module SellersHelper
  def self.generate_seller_json(seller:)
    locations = seller.locations
    seller = seller.as_json
    seller['locations'] = locations.as_json
    seller['gift_card_amount'] = calculate_gift_card_amount(
      seller_id: seller['id']
    )
    seller['donation_amount'] = calculate_donation_amount(
      seller_id: seller['id']
    )
    seller['amount_raised'] = seller['gift_card_amount'] +
                              seller['donation_amount']
    seller['num_gift_cards'] = calculate_num_gift_cards(
      seller_id: seller['id']
    )
    seller['num_donations'] = calculate_num_donations(
      seller_id: seller['id']
    )
    seller['num_contributions'] = seller['num_gift_cards'] +
                                  seller['num_donations']

    seller
  end

  # calculates the amount raised from gift cards
  # seller_id: the actual id of the Seller. Seller.id
  # TODO(jmckibben): Make this a single SQL query instead of doing N queries
  def self.calculate_gift_card_amount(seller_id:)
    return 0 if Item.where(seller_id: seller_id).empty?

    GiftCardDetail.joins(:item)
                  .where(items: {
                           seller_id: seller_id,
                           refunded: false
                         })
                  .inject(0) do |sum, gift_card|
      sum + gift_card.amount
    end
  end

  # calculates the amount raised from donations
  # seller_id: the actual id of the Seller. Seller.id
  def self.calculate_donation_amount(seller_id:)
    return 0 if Item.where(seller_id: seller_id).empty?

    DonationDetail.joins(:item)
                  .where(items: {
                           seller_id: seller_id,
                           refunded: false
                         })
                  .inject(0) do |sum, donation|
      sum + donation.amount
    end
  end

  # calculates the number of gift cards sold for seller
  # seller_id: the actual id of the Seller. Seller.id
  def self.calculate_num_gift_cards(seller_id:)
    return 0 if Item.where(seller_id: seller_id).empty?

    GiftCardDetail.joins(:item)
                  .where(items: {
                           seller_id: seller_id,
                           refunded: false
                         })
                  .size
  end

  # calculates the number of donations received by seller
  # seller_id: the actual id of the Seller. Seller.id
  def self.calculate_num_donations(seller_id:)
    return 0 if Item.where(seller_id: seller_id).empty?

    DonationDetail.joins(:item)
                  .where(items: {
                           seller_id: seller_id,
                           refunded: false
                         })
                  .size
  end
end
