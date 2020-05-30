# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SellersHelper, type: :helper do
  let(:contact) { create :contact }
  let(:seller) { create :seller, distributor: contact }

  # TODO(jxue) add some tests including returned giftcards/donations

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
        'gallery_image_urls': [],
        'business_type': seller.business_type,
        'num_employees': seller.num_employees,
        'founded_year': seller.founded_year,
        'website_url': seller.website_url,
        'menu_url': seller.menu_url,
        'square_location_id': seller.square_location_id,
        'distributor': contact,
        'cost_per_meal': seller.cost_per_meal
      }.as_json
    end

    context 'with no money raised' do
      it 'returns the list of sellers with `and`' do
        expected_seller['amount_raised'] = 0
        expected_seller['donation_amount'] = 0
        expected_seller['gift_card_amount'] = 0
        expected_seller['num_contributions'] = 0
        expected_seller['num_gift_cards'] = 0
        expected_seller['num_donations'] = 0
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

        # Create a donation of $200
        item_donation1 = create(:item, seller: seller)
        create(:donation_detail, item: item_donation1, amount: 200_00)

        # Create a donation of $10
        item_donation2 = create(:item, seller: seller)
        create(:donation_detail, item: item_donation2, amount: 10_00)

        expected_seller['donation_amount'] = 210_00
        expected_seller['amount_raised'] = 290_00
        expected_seller['gift_card_amount'] = 80_00
        expected_seller['num_contributions'] = 4
        expected_seller['num_gift_cards'] = 2
        expected_seller['num_donations'] = 2
      end

      it 'returns the list of sellers with `and`' do
        expect(SellersHelper.generate_seller_json(seller: seller))
          .to eq(expected_seller)
      end
    end
  end
end
