# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SellersHelper, type: :helper do
  let(:seller) { create :seller }

  describe 'generate_seller_json' do
    let(:expected_seller) do
      {
        'id': seller.id,
        'seller_id': seller.seller_id,
        'cuisine_name': seller.cuisine_name,
        'name': seller.name,
        'story': seller.story,
        'accept_donations': seller.accept_donations,
        'sell_gift_cards': seller.sell_gift_cards,
        'owner_name': seller.owner_name,
        'owner_image_url': seller.owner_image_url,
        'created_at': seller.created_at,
        'updated_at': seller.updated_at,
        'target_amount': seller.target_amount,
        'summary': seller.summary,
        'progress_bar_color': seller.progress_bar_color,
        'hero_image_url': seller.hero_image_url,
        'locations': [],
        'business_type': seller.business_type,
        'num_employees': seller.num_employees,
        'founded_year': seller.founded_year,
        'website_url': seller.website_url,
        'menu_url': seller.menu_url,
        'square_location_id': seller.square_location_id
      }.as_json
    end

    context 'with no money raised' do
      it 'returns the list of sellers with `and`' do
        expected_seller['amount_raised'] = 0
        expect(SellersHelper.generate_seller_json(seller: seller))
          .to eq(expected_seller)
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
        expected_seller['amount_raised'] = 290_00
        expect(SellersHelper.generate_seller_json(seller: seller))
          .to eq(expected_seller)
      end
    end
  end

  describe '#calculate_amount_raised' do
    context 'with no money raised' do
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
