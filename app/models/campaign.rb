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
#  target_amount      :integer          default(100000), not null
#  valid              :boolean          default(TRUE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  distributor_id     :bigint
#  location_id        :bigint           not null
#  nonprofit_id       :bigint
#  seller_id          :bigint           not null
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
class Campaign < ApplicationRecord
  # TODO(justintmckibben): Make the default value of valid = true
  belongs_to :location
  belongs_to :seller
  belongs_to :distributor

  scope :active, ->(active) { where(active: active) }

  def amount_raised
    # NB(justintmckibben): Currently campaigns are designed only for GAM and
    # therefore only create gift cards. For campaigns where we don't need the
    # gift cards aka we distribute hot meals, we *could* create donations
    # instead of gift cards
    gift_card_amount
  end

  def last_contribution
    Item.where(
      campaign_id: id,
      refunded: false,
      item_type: :gift_card
    ).order(created_at: :desc).first&.created_at
  end

  def seller_distributor_pairs
    pairs = []

    csd_pairings = CampaignsSellersDistributor
      .joins(:campaign)
      .where(campaigns: {
        id: id
      })

    seller_ids = csd_pairings.map {|pairing| pairing.seller_id}
    sellers = Seller.where(:id => seller_ids)
    seller_id_to_seller = {}
    sellers.each do |seller|
      seller_id_to_seller[seller.id] = seller
    end

    distributor_ids = csd_pairings.map {|pairing| pairing.distributor_id}
    distributors = Distributor.where(:id => distributor_ids)
    distributor_id_to_distributor = {}
    distributors.each do |distributor|
      distributor_id_to_distributor[distributor.id] = distributor
    end

    csd_pairings.each do |pairing|
      seller = seller_id_to_seller[pairing.seller_id]
      distributor = distributor_id_to_distributor[pairing.distributor_id]
      pair = {
        'distributor_id' => distributor.id,
        'distributor_image_url' => distributor.image_url,
        'distributor_name' => distributor.name,
        'seller_id' => seller.id,
        'seller_image_url' => seller.hero_image_url,
        'seller_name' => seller.name,
      }
      pairs.append(pair)
    end

    pairs
  end

  private

  # calculates the amount raised from gift cards
  def gift_card_amount
    GiftCardDetail
      .joins(:item)
      .where(items: {
               campaign_id: id,
               refunded: false
             })
      .joins("join (#{GiftCardAmount.original_amounts_sql}) as la on la.gift_card_detail_id = gift_card_details.id")
      .sum(:value)
  end
end
