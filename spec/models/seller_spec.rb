# frozen_string_literal: true

# == Schema Information
#
# Table name: sellers
#
#  id                      :bigint           not null, primary key
#  accept_donations        :boolean          default(TRUE), not null
#  business_type           :string
#  cost_per_meal           :integer
#  cuisine_name            :string
#  founded_year            :integer
#  gallery_image_urls      :string           default([]), not null, is an Array
#  gift_cards_access_token :string           default(""), not null
#  hero_image_url          :string
#  logo_image_url          :string
#  menu_url                :string
#  name                    :string
#  num_employees           :integer
#  owner_image_url         :string
#  owner_name              :string
#  progress_bar_color      :string
#  sell_gift_cards         :boolean          default(FALSE), not null
#  story                   :text
#  summary                 :text
#  target_amount           :integer          default(1000000)
#  website_url             :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  non_profit_location_id  :string
#  seller_id               :string           not null
#  square_location_id      :string           not null
#
# Indexes
#
#  index_sellers_on_gift_cards_access_token  (gift_cards_access_token) UNIQUE
#  index_sellers_on_seller_id                (seller_id)
#
require 'rails_helper'

RSpec.describe Seller, type: :model do
  # Association test
  # ensure Seller model has a 1:m relationship with the MenuItem model
  it { should have_many(:menu_items).dependent(:destroy) }
  it { should have_many(:delivery_options).dependent(:destroy) }
  it { should have_many(:fees).dependent(:destroy) }
  it { should have_one(:distributor) }
  # Validation tests

  let!(:seller) do
    create(:seller)
  end

  it 'has valid seller_id' do
    should validate_uniqueness_of(:seller_id)
    should validate_presence_of(:seller_id)
  end

  it 'has valid square_location_id' do
    should validate_uniqueness_of(:square_location_id)
    should validate_presence_of(:square_location_id)
  end

  it 'has valid attributes for sell_gift_cards attribute' do
    should allow_value(%w[true false]).for(:sell_gift_cards)
  end

  it 'has valid attributes for accept_donations attributes' do
    should allow_value(%w[true false]).for(:accept_donations)
  end

  it 'is valid target_amount' do
    expect(seller.target_amount).to eq 1_000_000
  end

  it 'is invalid without seller_id' do
    seller.seller_id = nil
    expect(seller).to_not be_valid
  end

  it 'is invalid without square_location_id' do
    seller.square_location_id = nil
    expect(seller).to_not be_valid
  end

  it 'generates a gift_cards_access_token' do
    expect(seller.gift_cards_access_token.present?).to eq true
  end

  describe 'globalization' do
    context 'with Chinese locale' do
      before do
        I18n.locale = 'zh-CN'
      end

      it 'uses Chinese' do
        expect(seller.story[0..4]).to eq 'zh-CN'
        expect(seller.summary[0..4]).to eq 'zh-CN'
        expect(seller.name[0..4]).to eq 'zh-CN'
        expect(seller.owner_name[0..4]).to eq 'zh-CN'
      end
    end

    context 'with default locale' do
      before do
        I18n.locale = I18n.default_locale
      end

      it 'uses English' do
        expect(seller.story[0..1]).to eq 'en'
        expect(seller.summary[0..1]).to eq 'en'
        expect(seller.name[0..1]).to eq 'en'
        expect(seller.owner_name[0..1]).to eq 'en'
      end
    end

    context 'with English locale' do
      before do
        I18n.locale = 'en'
      end

      it 'uses English' do
        expect(seller.story[0..1]).to eq 'en'
        expect(seller.summary[0..1]).to eq 'en'
        expect(seller.name[0..1]).to eq 'en'
        expect(seller.owner_name[0..1]).to eq 'en'
      end
    end
  end

  # test founding year constraints
  let(:time_travelling_seller) do
    create(
      :seller,
      founded_year: founded_year
    )
  end

  context 'test pre-1800 founding year' do
    let(:founded_year) { 1 }

    it 'raises an error' do
      expect do
        time_travelling_seller
        # TODO: make this a more informative error message
      end.to raise_error(
        ActiveRecord::RecordInvalid,
        'Validation failed: Founded year is not included in the list'
      )
    end
  end

  describe '#amount_raised' do
    context 'amount with no money raised' do
      it 'returns zero gift cards' do
        expect(seller.gift_card_amount).to eq(0)
        expect(seller.num_gift_cards).to eq(0)
        expect(seller.donation_amount).to eq(0)
        expect(seller.num_donations).to eq(0)
        expect(seller.num_contributions).to eq(0)
        expect(seller.amount_raised).to eq(0)
      end
    end

    context 'amount with money raised' do
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
        # Extraneous gift card amounts that should be ignored since it only
        # should use the most recent ammount (aka the one updated a day later)
        create(
          :gift_card_amount,
          value: 50_00,
          gift_card_detail: gift_card_detail2
        )
        create(
          :gift_card_amount,
          value: 50_00,
          gift_card_detail: gift_card_detail2
        )

        # Create $100 gift card, refunded
        item_gift_card3 = create(:item, seller: seller, refunded: true)
        gift_card_detail3 = create(:gift_card_detail, item: item_gift_card3)
        create(
          :gift_card_amount,
          value: 100_00,
          gift_card_detail: gift_card_detail3
        )

        # Create a donation of $200
        item_donation1 = create(:item, seller: seller)
        create(:donation_detail, item: item_donation1, amount: 200_00)

        # Create a donation of $10
        item_donation2 = create(:item, seller: seller)
        create(:donation_detail, item: item_donation2, amount: 10_00)

        # Create a donation of $50, refunded
        item_donation3 = create(:item, seller: seller, refunded: true)
        create(:donation_detail, item: item_donation3, amount: 50_00)
      end

      it 'returns gift card amounts' do
        expect(seller.gift_card_amount).to eq(80_00)
        expect(seller.num_gift_cards).to eq(2)
      end

      it 'returns donation amounts' do
        expect(seller.donation_amount).to eq(210_00)
        expect(seller.num_donations).to eq(2)
      end

      it 'returns total amount' do
        expect(seller.amount_raised).to eq(290_00)
        expect(seller.num_contributions).to eq(4)
      end
    end
  end

  context 'test future founding year' do
    let(:founded_year) { 3000 } # not much has changed but they live underwater

    it 'raises an error' do
      expect do
        time_travelling_seller
        # TODO: make this a more informative error message
      end.to raise_error(
        ActiveRecord::RecordInvalid,
        'Validation failed: Founded year is not included in the list'
      )
    end
  end
end
