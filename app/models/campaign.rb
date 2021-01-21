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
#  neighborhood       :string
#  price_per_meal     :integer          default(500)
#  start_date         :datetime
#  target_amount      :integer          default(100000), not null
#  valid              :boolean          default(TRUE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  distributor_id     :bigint
#  fee_id             :integer
#  location_id        :bigint
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
class Campaign < ApplicationRecord
  # TODO(justintmckibben): Make the default value of valid = true
  belongs_to :location
  belongs_to :seller, optional: true
  belongs_to :project, optional: true
  belongs_to :distributor, optional: true
  has_and_belongs_to_many :fees
  has_many :campaigns_sellers_distributors
  has_many :payment_intent
  validate :has_project_xor_seller?

  scope :active, ->(active) { where(active: active) }

  def amount_raised
    if mega_gam?
      # For Mega GAM campaigns, we don't generate items right away, so we rely
      # on the payment_intents table to determine the total amount raised.
      payment_intent_amount
    else
      # NB(justintmckibben): Currently campaigns are designed only for GAM and
      # therefore only create gift cards. For campaigns where we don't need the
      # gift cards aka we distribute hot meals, we *could* create donations
      # instead of gift cards
      gift_card_amount
    end
  end

  def amount_allocated
    # Amount allocated is always equal to the gift card amount. We allocate
    # payments immediately for regular GAM. For Mega GAM, we allocate after
    # the campaign is over.
    gift_card_amount
  end

  def amount_unallocated
    amount_raised - amount_allocated
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

    # TODO(justintmckibben): Remove this once we migrate seller and distributor
    # off of the campaign directly and to use CampaignsSellersDistributor
    # instead
    if seller.present? && distributor.present?
      pairs << seller_distributor_pair(
        seller: seller,
        distributor: distributor
      )
    end

    csd_pairings = CampaignsSellersDistributor
                   .joins(:campaign)
                   .where(campaigns: {
                            id: id
                          })

    csd_pairings.each do |pairing|
      pairs << seller_distributor_pair(
        seller: pairing.seller,
        distributor: pairing.distributor
      )
    end

    pairs
  end

  def display_name
    # Right now, we require campaigns to have a project or seller assocated
    # with them. we default to the corresponding project/seller name for the
    # campaign name.
    if project.present?
      project.name
    else
      # If there's no project, there will be a single seller/distributor
      # associated with the campaign.
      seller = Seller.find_by(seller_id: seller_distributor_pairs[0]['seller_id'])
      distributor = Distributor.find(seller_distributor_pairs[0]['distributor_id'])
      seller.name + ' x ' + distributor.name
    end
  end

  def mega_gam?
    project.present?
  end

  private

  def seller_distributor_pair(seller:, distributor:)
    {
      'distributor_id' => distributor.id,
      'distributor_image_url' => distributor.image_url,
      'distributor_website_url' => distributor.website_url,
      'distributor_name' => distributor.name,
      'seller_id' => seller.seller_id,
      'seller_non_profit_location_id' => seller.non_profit_location_id,
      'seller_image_url' => seller.hero_image_url,
      'seller_name' => seller.name,
      'seller_city' => seller.locations.size > 0 ? seller.locations.first.city : nil
    }
  end

  # Calculates the amount raised in the payment intent table.
  def payment_intent_amount
    payment_intents = PaymentIntent
      .joins(:campaign)
      .where(campaigns: {
               id: id
             })
      .where(successful: true)
      .as_json

    # Ignore transaction fees when calculating the total amount raised
    total_amount_raised = 0
    payment_intents.each do |payment|
      line_items = JSON.parse(payment["line_items"])
      amount = line_items
        .select{ |line_item| line_item["item_type"] == "donation" }
        .map{ |donation_line_item| donation_line_item["amount"] }
        .sum
      total_amount_raised += amount
    end
    total_amount_raised
  end

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

  def has_project_xor_seller?
    unless project.present? ^ seller.present?
      errors.add(:project, 'Project or Seller must exist, but not both')
      errors.add(:seller, 'Project or Seller must exist, but not both')
    end
  end
end
