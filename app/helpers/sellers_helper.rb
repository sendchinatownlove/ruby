module SellersHelper
  def self.generate_seller_json(seller:)
    seller = seller.as_json
    seller['amount_raised'] = SellersHelper.calculate_amount_raised(seller_id: seller['seller_id'])
    seller
  end

  def self.calculate_amount_raised(seller_id:)
    return 0 if Item.where(seller_id: seller_id).empty?

    donation_amount = DonationDetail.joins(:item)
                                    .where(items: { seller_id: seller_id })
                                    .inject(0) do |sum, donation|
      sum + donation.amount
    end

    # TODO(jmckibben): Make this a single SQL query instead of doing N queries
    gift_card_amount = GiftCardDetail.joins(:item)
                                     .where(items: { seller_id: seller_id })
                                     .inject(0) do |sum, gift_card|
      sum + gift_card.amount
    end

    gift_card_amount + donation_amount
  end
end
