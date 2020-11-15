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
#  project_id         :bigint
#  seller_id          :bigint
#
# Indexes
#
#  index_campaigns_on_distributor_id  (distributor_id)
#  index_campaigns_on_location_id     (location_id)
#  index_campaigns_on_nonprofit_id    (nonprofit_id)
#  index_campaigns_on_project_id      (project_id)
#  index_campaigns_on_seller_id       (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (seller_id => sellers.id)
#
require 'rails_helper'

RSpec.describe Campaign, type: :model do
  it { should belong_to(:location) }
  it { should belong_to(:distributor) }

  before { freeze_time }

  let!(:campaign) { create :campaign }
  let!(:project) { create :project }

  it 'should have default values' do
    expect(campaign.amount_raised).to eq(0)
    expect(campaign.last_contribution).to be_nil
  end

  context 'with amount raised for regular gam campaigns' do
    it 'returns gift card amounts' do
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

      expect(campaign.amount_raised).to eq(100_00)
      expect(campaign.last_contribution).to eq(Time.current + 1.day)
    end
  end
  
  context 'with amount raised for mega gam campaigns' do
    let!(:campaign) { create(:campaign, :with_sellers_distributors, :with_project, seller: nil) }

    it 'returns payment intent amounts' do
      # Expect these 2 to be counted. :with_line_items adds line items of value 600.
      payment_intent_1 = create(:payment_intent, :with_line_items, campaign: campaign, successful: true)
      payment_intent_2 = create(:payment_intent, :with_line_items, campaign: campaign, successful: true)
      # Do not expect this one to be counted since it's not successful.
      payment_intent_3 = create(:payment_intent, :with_line_items, campaign: campaign, successful: false)

      expect(campaign.amount_raised).to eq 1200
    end
  end

  context 'with seller distributor pairs' do
    let!(:campaign) { create(:campaign, :with_sellers_distributors) }

    it 'gets seller distributor pairs' do
      csds = campaign.campaigns_sellers_distributors
      pairs = csds.map do |csd|
        {
          'distributor_id' => csd.distributor.id,
          'distributor_image_url' => csd.distributor.image_url,
          'distributor_name' => csd.distributor.name,
          'seller_id' => csd.seller.id,
          'seller_image_url' => csd.seller.hero_image_url,
          'seller_name' => csd.seller.name
        }
      end

      expect(campaign.seller_distributor_pairs).to eq(pairs)
    end
  end

  let(:seller) do
    create :seller
  end

  context 'when creating a campaign with only a project' do
    let(:campaign) do
      create(:campaign, seller: nil, project: project)
    end

    it 'is successful' do
      campaign
    end
  end

  context 'when creating a campaign with only a seller' do
    let(:campaign) do
      # factory associates a seller by default
      create :campaign
    end

    it 'is successful' do
      campaign
    end
  end

  context 'when creating a campaign with a project and seller' do
    let(:campaign) do
      Campaign.create(project: project, seller: seller)
    end

    subject { campaign }

    it 'throws an error' do
      expect(subject).to_not be_valid

      expect(subject.errors[:seller]).to include('Project or Seller must exist, but not both')
      expect(subject.errors[:project]).to include('Project or Seller must exist, but not both')
    end
  end

  context 'when creating an campaign with neither a project nor a seller' do
    let(:campaign) do
      Campaign.create(project: nil, seller: nil)
    end

    subject { campaign }

    it 'throws an error' do
      expect(subject).to_not be_valid

      expect(subject.errors[:project]).to include('Project or Seller must exist, but not both')
      expect(subject.errors[:seller]).to include('Project or Seller must exist, but not both')
    end
  end
end
