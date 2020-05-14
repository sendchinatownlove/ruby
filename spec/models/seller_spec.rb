# frozen_string_literal: true

# == Schema Information
#
# Table name: sellers
#
#  id                 :bigint           not null, primary key
#  accept_donations   :boolean          default(TRUE), not null
#  business_type      :string
#  cuisine_name       :string
#  founded_year       :integer
#  hero_image_url     :string
#  menu_url           :string
#  name               :string
#  num_employees      :integer
#  owner_image_url    :string
#  owner_name         :string
#  progress_bar_color :string
#  sell_gift_cards    :boolean          default(FALSE), not null
#  story              :text
#  summary            :text
#  target_amount      :integer          default(1000000)
#  website_url        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  seller_id          :string           not null
#  square_location_id :string           not null
#
# Indexes
#
#  index_sellers_on_seller_id  (seller_id)
#
require 'rails_helper'

RSpec.describe Seller, type: :model do
  # Association test
  # ensure Seller model has a 1:m relationship with the MenuItem model
  it { should have_many(:menu_items).dependent(:destroy) }
  it { should have_one(:recipient) }
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
