# frozen_string_literal: true

# == Schema Information
#
# Table name: sellers
#
#  id                 :bigint           not null, primary key
#  accept_donations   :boolean          default(TRUE), not null
#  business_type      :string
#  cost_per_meal      :integer
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
class Seller < ApplicationRecord
  # The `seller_id` of the special seller we use to collect pool donations.
  POOL_DONATION_SELLER_ID = 'send-chinatown-love'

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
  has_many :items, dependent: :destroy

  has_one :distributor, class_name: 'Contact'

  validates_presence_of :seller_id
  validates_presence_of :square_location_id

  validates_inclusion_of :founded_year, in: 1800..2020
  validates_uniqueness_of :seller_id
  validates_uniqueness_of :square_location_id
  validates_inclusion_of :sell_gift_cards, in: [true, false]
  validates_inclusion_of :accept_donations, in: [true, false]
end
