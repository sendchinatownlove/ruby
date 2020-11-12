# frozen_string_literal: true

# == Schema Information
#
# Table name: campaigns
#
#  id                 :bigint           not null, primary key
#  active             :boolean          default(FALSE)
#  description        :string
#  end_date           :datetime         not null
#  gallery_image_urls :string           is an Array
#  price_per_meal     :integer          default(500)
#  start_date         :datetime
#  target_amount      :integer          default(100000), not null
#  valid              :boolean          default(TRUE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  distributor_id     :bigint
#  location_id        :bigint           not null
#  nonprofit_id       :bigint
#  seller_id          :bigint
#
# Indexes
#
#  index_campaigns_on_distributor_id  (distributor_id)
#  index_campaigns_on_location_id     (location_id)
#  index_campaigns_on_nonprofit_id    (nonprofit_id)
#  index_campaigns_on_seller_id       (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (seller_id => sellers.id)
#
require 'rails_helper'

RSpec.describe Campaign, type: :model do
  it { should belong_to(:location) }
  it { should belong_to(:seller) }
  it { should belong_to(:distributor) }

  before { freeze_time }

  let!(:campaign) { create :campaign }

  it 'should have default values' do
    expect(campaign.amount_raised).to eq(0)
    expect(campaign.last_contribution).to be_nil
  end

  context 'with gift cards' do
    before do
      # Create $50 gift card
      item_gift_card1 = create(
        :item,
        campaign: campaign,
        item_type: :gift_card,
        created_at: Time.current
      )
      gift_card_detail1 = create(:gift_card_detail, item: item_gift_card1)
      create(
        :gift_card_amount,
        value: 50_00,
        gift_card_detail: gift_card_detail1
      )

      # Create second gift card, which is a $50 gift card with $20 spent
      item_gift_card2 = create(
        :item,
        campaign: campaign,
        item_type: :gift_card,
        created_at: Time.current + 1.day
      )
      gift_card_detail2 = create(
        :gift_card_detail,
        item: item_gift_card2
      )
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
      item_gift_card3 = create(
        :item,
        item_type: :gift_card,
        campaign: campaign,
        refunded: true
      )
      gift_card_detail3 = create(:gift_card_detail, item: item_gift_card3)
      create(
        :gift_card_amount,
        value: 100_00,
        gift_card_detail: gift_card_detail3
      )
    end

    it 'returns gift card amounts' do
      expect(campaign.amount_raised).to eq(100_00)
      expect(campaign.last_contribution).to eq(Time.current + 1.day)
    end
  end
end
