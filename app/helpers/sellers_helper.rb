module SellersHelper
  def self.generate_seller_json(seller:)
    locations = seller.locations
    seller = seller.as_json
    seller['locations'] = locations.as_json
    seller['amount_raised'] = SellersHelper.calculate_amount_raised(seller_id: seller['id'])
    seller
  end

  # Calculates the amount of money raised by the Seller so far.
  # seller_id: the actual id of the Seller. Seller.id
  def self.calculate_amount_raised(seller_id:)
    return 0 if Item.where(seller_id: seller_id).empty?

    donation_amount = DonationDetail.joins(:item)
                                    .where(items: { seller_id: seller_id, refunded: false })
                                    .inject(0) do |sum, donation|
      sum + donation.amount
    end

    # TODO(jmckibben): Make this a single SQL query instead of doing N queries
    gift_card_amount = GiftCardDetail.joins(:item)
                                     .where(items: { seller_id: seller_id, refunded: false })
                                     .inject(0) do |sum, gift_card|
      sum + gift_card.amount
    end

    gift_card_amount + donation_amount
  end
end
