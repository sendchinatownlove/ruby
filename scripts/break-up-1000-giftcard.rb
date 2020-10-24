=begin
Break up a single $1000 gift card purchase into 100 $10 gift cards

This was done due to one single large purchase that someone wanted to distribute
the gift cards to members of their organization.
=end

Item.transaction do
    # a priori
    big_card_id = 9826
    total_amount = 100000 # $1000
    num_cards = 100
    
    # retrieve info and setup
    target_seller = Seller.find_by(seller_id: 'wonton-noodle-garden')
    big_card_gcd = GiftCardDetail.find(big_card_id)
    big_card_gca = GiftCardAmount.find_by(gift_card_detail_id: big_card_id);
    big_card_item = big_card_gcd.item
    big_card_amount = big_card_gca.value
    big_card_contact = big_card_item.purchaser
    amount_per_card = total_amount / num_cards
    
    # sanity check
    if (total_amount != big_card_amount ||
        big_card_item.seller != target_seller)
            raise ActiveRecord::Rollback, "retrieved info does not match a priori info"
    end

    # act
    big_card_gca.update!(value: 0)
    big_card_item.update!(refunded: true)

    (1..num_cards).each do |i|
        puts("creating gift card #{i} of #{num_cards}")
        item = Item.create!(
          seller: target_seller,
          item_type: "gift_card",
          purchaser: big_card_contact
        )
        gift_card_detail = GiftCardDetail.create!(
          recipient: big_card_contact,
          item_id: item.id,
          gift_card_id: GiftCardIdGenerator.generate_gift_card_id,
          seller_gift_card_id: GiftCardIdGenerator.generate_seller_gift_card_id(seller_id: '88-lanzhou'),
          single_use: false
        )
        GiftCardAmount.create!(
          gift_card_detail_id: gift_card_detail.id,
          value: amount_per_card
        )
    end
end

#-- Forgot to update the payment intent, so did a second pass

Item.transaction do
    original = Item.find(15170)

    created_items = Item.where(purchaser_id: 3210, payment_intent_id: nil)
    
    created_items.each do |item|
        item.update!(payment_intent: original.payment_intent)
    end
end