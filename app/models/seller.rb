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
class Seller < ApplicationRecord
  # The `seller_id` of the special seller we use to collect pool donations.
  POOL_DONATION_SELLER_ID = 'send-chinatown-love'

  # NOTE: POOL_DONATION_SELLER_ID does not accept donations
  scope :filter_by_accepts_donations, -> { where(accept_donations: true) }

  translates :name, :story, :owner_name, :summary, :business_type
  globalize_accessors locales: [:en, 'zh-CN'],
                      attributes: %i[
                        name
                        story
                        owner_name
                        summary
                        business_type
                      ]

  # model association
  has_many :locations, dependent: :destroy
  has_many :menu_items, dependent: :destroy
  has_many :delivery_options, dependent: :destroy
  has_many :open_hour, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :fees, dependent: :destroy

  validates_presence_of :seller_id
  validates_presence_of :square_location_id

  validates_inclusion_of :founded_year, in: 1800..2020
  validates_uniqueness_of :seller_id
  validates_uniqueness_of :square_location_id
  validates_inclusion_of :sell_gift_cards, in: [true, false]
  validates_inclusion_of :accept_donations, in: [true, false]

  before_create :set_gift_cards_access_token

  # returns the total amount raised
  def amount_raised
    gift_card_amount + donation_amount
  end

  # calculates the amount raised from gift cards
  def gift_card_amount
    GiftCardDetail
      .joins(:item)
      .where(items: {
               seller_id: id,
               refunded: false
             })
      .joins("join (#{GiftCardAmount.latest_amounts_sql}) as la on la.gift_card_detail_id = gift_card_details.id")
      .sum(:value)
  end

  # calculates the amount raised from donations
  def donation_amount
    DonationDetail
      .joins(:item)
      .where(items: {
               seller_id: id,
               refunded: false
             })
      .sum(:amount)
  end

  def num_contributions
    num_gift_cards + num_donations
  end

  # calculates the number of gift cards sold for seller
  # seller_id: the actual id of the Seller. Seller.id
  def num_gift_cards
    GiftCardDetail.joins(:item)
                  .where(items: {
                           seller_id: id,
                           refunded: false
                         })
                  .size
  end

  # calculates the number of donations received by seller
  # seller_id: the actual id of the Seller. Seller.id
  def num_donations
    DonationDetail.joins(:item)
                  .where(items: {
                           seller_id: id,
                           refunded: false
                         })
                  .size
  end

  private

  def set_gift_cards_access_token
    self.gift_cards_access_token = generate_gift_cards_access_token
  end

  def generate_gift_cards_access_token
    loop do
      token = SecureRandom.uuid
      break token unless Seller.where(gift_cards_access_token: token).exists?
    end
  end
end
