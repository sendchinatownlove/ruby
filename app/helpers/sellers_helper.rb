module SellersHelper
  def calculate_amount_raised(seller_id:)
    return 0 if Item.where(seller_id: seller_id).empty?

    donation_amount = DonationDetail.joins(:item)
                                    .where(items: { seller_id: seller_id })
                                    .inject(0) do |sum, donation|
      sum + donation.amount
    end
    # SOS HALP MEEEEE
    gift_card_amount_ids = GiftCardAmount.group(:gift_card_detail_id).maximum(:updated_at).keys
    gift_card_amounts = GiftCardAmount(id: gift_card_amount_ids)
                             .joins(:gift_card_detail)
                             .joins(:item)
                             .where(items: { seller_id: seller_id })

    gift_card_amount = gift_card_amounts.inject(0) do |sum, gift_card|
      sum + gift_card.amount
    end

    gift_card_amount + donation_amount
  end
end
