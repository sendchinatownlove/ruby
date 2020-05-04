# frozen_string_literal: true

module SellersHelper
  def self.generate_seller_json(seller:)
    locations = seller.locations
    seller = seller.as_json
    seller['locations'] = locations.as_json
    gift_card_amount = SellersHelper.calculate_gift_card_amount(
      seller_id: seller['id']
    )
    donation_amount = SellersHelper.calculate_donation_amount(
      seller_id: seller['id']
    )
    seller['gift_card_amount'] = gift_card_amount
    seller['donation_amount'] = donation_amount
    seller['amount_raised'] = gift_card_amount + donation_amount
    num_gift_cards = SellersHelper.calculate_num_gift_cards(
      seller_id: seller['id']
    )
    num_donations = SellersHelper.calculate_num_donations(
      seller_id: seller['id']
    )
    seller['num_gift_cards'] = num_gift_cards
    seller['num_donations'] = num_donations
    seller['num_contributions'] = num_gift_cards + num_donations

    seller
  end

  # calculates the amount raised from gift cards
  # seller_id: the actual id of the Seller. Seller.id
  def self.calculate_gift_card_amount(seller_id:)
    return 0 if Item.where(seller_id: seller_id).empty?

    gift_card_amount = GiftCardDetail.joins(:item)
                                     .where(items: {
                                              seller_id: seller_id,
                                              refunded: false
                                            })
                                     .inject(0) do |sum, gift_card| sum + gift_card.amount
                                      end
    gift_card_amount
    end

  # calculates the amount raised from donations
  # seller_id: the actual id of the Seller. Seller.id
  def self.calculate_donation_amount(seller_id:)
    donation_amount = DonationDetail.joins(:item)
                                    .where(items: {
                                             seller_id: seller_id,
                                             refunded: false
                                           })
                                    .inject(0) do |sum, donation| sum + donation.amount
                                    end
    donation_amount
    end

  # calculates the number of gift cards sold for seller
  # seller_id: the actual id of the Seller. Seller.id
  # TODO (jxue) I think there's a way to count activerecords directly but I can't remember
  def self.calculate_num_gift_cards(seller_id:)
    return 0 if Item.where(seller_id: seller_id).empty?

    num_gift_cards = GiftCardDetail.joins(:item)
                                     .where(items: {
                                              seller_id: seller_id,
                                              refunded: false
                                            })
                                     .inject(0) do |sum, gift_card| sum + 1 
                                     end
    num_gift_cards
    end

  # calculates the number of donations received by seller
  # seller_id: the actual id of the Seller. Seller.id
  # TODO (jxue) I think there's a way to count activerecords directly but I can't remember
  def self.calculate_num_donations(seller_id:)
    num_donations = DonationDetail.joins(:item)
                                    .where(items: {
                                             seller_id: seller_id,
                                             refunded: false
                                           })
                                    .inject(0) do |sum, donation| sum + 1
                                    end
    num_donations
    end


  # Calculates the amount of money raised by the Seller so far.
  # seller_id: the actual id of the Seller. Seller.id

  # def self.calculate_amount_raised(seller_id:)
  #   return 0 if Item.where(seller_id: seller_id).empty?

  #   donation_amount = DonationDetail.joins(:item)
  #                                   .where(items: {
  #                                            seller_id: seller_id,
  #                                            refunded: false
  #                                          })
  #                                   .inject(0) do |sum, donation|
  #     sum + donation.amount
  #   end

  #   # TODO(jmckibben): Make this a single SQL query instead of doing N queries
  #   gift_card_amount = GiftCardDetail.joins(:item)
  #                                    .where(items: {
  #                                             seller_id: seller_id,
  #                                             refunded: false
  #                                           })
  #                                    .inject(0) do |sum, gift_card|
  #     sum + gift_card.amount
  #   end

  #   gift_card_amount + donation_amount
  # end
end


