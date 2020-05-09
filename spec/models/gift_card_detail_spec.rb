# frozen_string_literal: true

# == Schema Information
#
# Table name: gift_card_details
#
#  id                  :bigint           not null, primary key
#  expiration          :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  gift_card_id        :string
#  item_id             :bigint           not null
#  receipt_id          :string
#  seller_gift_card_id :string
#
# Indexes
#
#  index_gift_card_details_on_item_id  (item_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => items.id)
#
require 'rails_helper'

RSpec.describe GiftCardDetail, type: :model do
  let(:item1) do
    create(
      :item,
      seller: seller1
    )
  end
  let(:item2) do
    create(
      :item,
      seller: seller2
    )
  end

  let(:gift_card_detail1) do
    create(
      :gift_card_detail,
      gift_card_id: gift_card_id1,
      seller_gift_card_id: seller_gift_card_id1,
      item: item1
    )
  end
  let(:gift_card_detail2) do
    create(
      :gift_card_detail,
      gift_card_id: gift_card_id2,
      seller_gift_card_id: seller_gift_card_id2,
      item: item2
    )
  end

  before { create :gift_card_detail }
  it { should validate_uniqueness_of(:gift_card_id) }

  context 'with unique gift_card_id and seller_gift_card_id' do
    let(:gift_card_id1) { 'GIFTCARD1' }
    let(:seller_gift_card_id1) { '1111' }

    let(:gift_card_id2) { 'GIFTCARD2' }
    let(:seller_gift_card_id2) { '2222' }

    let(:seller1) { create :seller }
    let(:seller2) { create :seller }

    it 'sucessfully creates' do
      expect(gift_card_detail1.gift_card_id).to eq(gift_card_id1)
      expect(gift_card_detail1.seller_gift_card_id).to eq(seller_gift_card_id1)

      expect(gift_card_detail2.gift_card_id).to eq(gift_card_id2)
      expect(gift_card_detail2.seller_gift_card_id).to eq(seller_gift_card_id2)
    end
  end

  context 'when gift_card_id is taken' do
    let(:gift_card_id1) { 'GIFTCARD' }
    let(:seller_gift_card_id1) { '1111' }

    let(:gift_card_id2) { 'GIFTCARD' }
    let(:seller_gift_card_id2) { '2222' }

    let(:seller1) { create :seller }
    let(:seller2) { create :seller }

    it 'raises an error' do
      gift_card_detail1
      expect do
        gift_card_detail2
      end.to raise_error(
        ActiveRecord::RecordInvalid,
        'Validation failed: Gift card has already been taken'
      )
    end
  end

  context 'when seller_gift_card_id is taken by another seller' do
    let(:seller1) { create :seller }
    let(:seller2) { create :seller }

    let(:gift_card_id1) { 'GIFTCARD1' }
    let(:seller_gift_card_id1) { 'xxxx' }

    let(:gift_card_id2) { 'GIFTCARD2' }
    let(:seller_gift_card_id2) { 'xxxx' }

    it 'should create with no problems' do
      expect(gift_card_detail1.gift_card_id).to eq(gift_card_id1)
      expect(gift_card_detail1.seller_gift_card_id).to eq(seller_gift_card_id1)

      expect(gift_card_detail2.gift_card_id).to eq(gift_card_id2)
      expect(gift_card_detail2.seller_gift_card_id).to eq(seller_gift_card_id2)
    end
  end

  context 'when seller_gift_card_id is taken' do
    let(:seller1) { create :seller }
    let(:seller2) { seller1 }

    let(:gift_card_id1) { 'GIFTCARD1' }
    let(:seller_gift_card_id1) { 'xxxx' }

    let(:gift_card_id2) { 'GIFTCARD2' }
    let(:seller_gift_card_id2) { 'xxxx' }

    it 'raises an error' do
      gift_card_detail1
      expect do
        gift_card_detail2
      end.to raise_error(
        ActiveRecord::RecordInvalid,
        # rubocop:disable Layout/LineLength
        'Validation failed: Seller gift card seller_gift_card_id must be unique per Seller'
        # rubocop:enable Layout/LineLength
      )
    end
  end
end
