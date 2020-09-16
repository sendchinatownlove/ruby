# frozen_string_literal: true

# Creates donation and item with the corresponding payload
module WebhookManager
  class PoolDonationCreator < BaseService
    attr_reader :seller_id, :payment_intent, :amount

    def initialize(params)
      @seller_id = params[:seller_id]
      @payment_intent = params[:payment_intent]
      @amount = params[:amount]
    end

    def call
      ActiveRecord::Base.transaction do
        # TODO(jtmckibb): This is a very inefficient sort, since each time we
        #                 call amount_raised, it has to fetch all of the
        #                 associated Items, DonationDetails, and GiftCardDetails
        #                 Then for each GiftCardDetail, it has to fetch every
        #                 amount in an N+1 query, then sum everything. This is
        #                 all in an N log N sort—which is horrible. Ideally,
        #                 we would memoize amount_raised, and fix the N+1 query
        #                 in GiftCardDetail that calculates amount.
        @donation_sellers = Seller.filter_by_accepts_donations.sort_by(&:amount_raised)

        # calculate amount per merchant
        # This will break if we ever have zero merchants but are still
        # accepting pool donations.
        amount_after_fees = WebhookManager::FeeHandler.call({
          payment_intent: payment_intent,
          amount: amount
        })
        amount_per = (amount_after_fees.to_f / @donation_sellers.count.to_f).floor
        remainder = amount_after_fees % @donation_sellers.count

        donations = @donation_sellers.map do |seller|
          next if seller.seller_id.eql?(Seller::POOL_DONATION_SELLER_ID)

          item = WebhookManager::ItemCreator.call({
                                                    item_type: :donation,
                                                    seller_id: seller.seller_id,
                                                    payment_intent: payment_intent
                                                  })

          donation = DonationDetail.create!(
            item: item,
            amount: amount_per + (remainder > 0 ? 1 : 0)
          )

          remainder -= 1

          donation
        end

        payment_intent.successful = true
        payment_intent.save!

        donations
      end
    end
  end
end
