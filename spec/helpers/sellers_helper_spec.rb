# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SellersHelper, type: :helper do
  let(:seller) { create :seller, :with_campaign }

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
        'logo_image_url': seller.logo_image_url,
        'summary': seller.summary,
        'progress_bar_color': seller.progress_bar_color,
        'hero_image_url': seller.hero_image_url,
        'locations': [],
        'fees': [],
        'gallery_image_urls': [],
        'business_type': seller.business_type,
        'num_employees': seller.num_employees,
        'founded_year': seller.founded_year,
        'website_url': seller.website_url,
        'menu_url': seller.menu_url,
        'square_location_id': seller.square_location_id,
        'distributor': seller.campaigns.first.distributor.contact,
        'cost_per_meal': seller.cost_per_meal,
        'non_profit_location_id': seller.non_profit_location_id,
        'amount_raised': 0,
        'donation_amount': 0,
        'gift_card_amount': 0,
        'gift_a_meal_amount': 0,
        'num_contributions': 0,
        'num_gift_cards': 0,
        'num_donations': 0
      }.as_json
    end

    context 'with cost_per_meal' do
      before do
        seller.update(cost_per_meal: 1000)
      end

      it 'returns the seller with normal cost per meal' do
        expected_seller['cost_per_meal'] = 1000
        expect(SellersHelper.generate_seller_json(seller: seller))
          .to eq(expected_seller)
      end

      context 'with fee' do
        let!(:fee) { create :fee, seller: seller, multiplier: 0.1 }

        it 'returns the seller with normal cost per meal including fees' do
          expected_seller['cost_per_meal'] = 1100
          expected_seller['fees'] = [fee.as_json]
          expect(SellersHelper.generate_seller_json(seller: seller))
            .to eq(expected_seller)
        end
      end
    end

    context 'with no money raised' do
      it 'returns the list of sellers with `and`' do
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
          created_at: Time.current + 1.day
        )

        # Create gift-a-meal gift card of $10.
        gift_a_meal1 = create(:item, seller: seller)
        gift_card_detail3 = create(:gift_card_detail, item: item_gift_card1, single_use: true)
        create(
          :gift_card_amount,
          value: 10_00,
          gift_card_detail: gift_card_detail3,
        )
        
        # Create a donation of $200
        item_donation1 = create(:item, seller: seller)
        create(:donation_detail, item: item_donation1, amount: 200_00)

        # Create a donation of $10
        item_donation2 = create(:item, seller: seller)
        create(:donation_detail, item: item_donation2, amount: 10_00)

        expected_seller['donation_amount'] = 210_00
        expected_seller['amount_raised'] = 320_00
        expected_seller['gift_card_amount'] = 110_00
        expected_seller['gift_a_meal_amount'] = 10_00
        expected_seller['num_contributions'] = 5
        expected_seller['num_gift_cards'] = 3
        expected_seller['num_donations'] = 2
      end

      it 'returns the list of sellers with `and`' do
        expect(SellersHelper.generate_seller_json(seller: seller))
          .to eq(expected_seller)
      end
    end
  end
end
