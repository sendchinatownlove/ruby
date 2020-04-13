require 'rails_helper'

RSpec.describe SellersHelper, type: :helper do
  describe '#calculate_amount_raised' do
    let(:seller) { create :seller }
    context 'with no money raised' do

      it 'returns the list of sellers with `and`' do
        expect(helper.calculate_amount_raised(seller_id: seller.id)).to eq(0)
      end
    end

    context 'with money raised' do
      before do
        # Create $50 gift card
        item_gift_card1 = create(:item, seller: seller)
        gift_card_detail1 = create(:gift_card_detail, item: item_gift_card1)
        gift_card1_amount1 = create(
          :gift_card_amount,
          value: 5000,
          gift_card_detail: gift_card_detail1
        )

        # Create second gift card, which is a $50 gift card with $20 spent
        item_gift_card2 = create(:item, seller: seller)
        gift_card_detail2 = create(:gift_card_detail, item: item_gift_card2)
        gift_card2_amount1 = create(
          :gift_card_amount,
          value: 5000,
          gift_card_detail: gift_card_detail2
        )
        # Updated a day later
        gift_card2_amount2 = create(
          :gift_card_amount,
          value: 3000,
          gift_card_detail: gift_card_detail2,
          updated_at: Time.current + 1.day
        )

        # Create a donation of $200
        item_donation1 = create(:item, seller: seller)
        donation_detail1 = create(:donation_detail, item: item_donation1, amount: 20000)

        # Create a donation of $10
        item_donation2 = create(:item, seller: seller)
        donation_detail2 = create(:donation_detail, item: item_donation2, amount: 1000)

        binding.pry
      end

      it 'returns the list of sellers with `and`' do
        expect(helper.calculate_amount_raised(seller_id: seller.id))
          .to eq(29000)
      end
    end
  end
end
