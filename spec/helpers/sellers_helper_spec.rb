require 'rails_helper'

RSpec.describe SellersHelper, type: :helper do
  describe '#calculate_amount_raised' do
    let(:seller) { create :seller }
    context.skip 'with no money raised' do

      it 'returns the list of sellers with `and`' do
        expect(SellersHelper.calculate_amount_raised(seller_id: seller.id)).to eq(0)
      end
    end

    context 'with money raised' do
      before do
        # Create $50 gift card
        item_gift_card1 = create(:item, seller: seller)
        gift_card_detail1 = create(:gift_card_detail, item: item_gift_card1)
        create(
          :gift_card_amount,
          value: 50_00,
          gift_card_detail: gift_card_detail1
        )

        # Create second gift card, which is a $50 gift card with $20 spent
        item_gift_card2 = create(:item, seller: seller)
        gift_card_detail2 = create(:gift_card_detail, item: item_gift_card2)
        create(
          :gift_card_amount,
          value: 50_00,
          gift_card_detail: gift_card_detail2
        )
        # Updated a day later
        create(
          :gift_card_amount,
          value: 30_00,
          gift_card_detail: gift_card_detail2,
          updated_at: Time.current + 1.day
        )

        # Create a donation of $200
        item_donation1 = create(:item, seller: seller)
        create(:donation_detail, item: item_donation1, amount: 200_00)

        # Create a donation of $10
        item_donation2 = create(:item, seller: seller)
        create(:donation_detail, item: item_donation2, amount: 10_00)
      end

      it 'returns the list of sellers with `and`' do
        expect(SellersHelper.calculate_amount_raised(seller_id: seller.id))
          .to eq(290_00)
      end
    end
  end
end
