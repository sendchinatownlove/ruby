# frozen_string_literal: true

# == Schema Information
#
# Table name: sellers
#
#  id                 :bigint           not null, primary key
#  seller_id          :string           not null
#  cuisine_name       :string
#  accept_donations   :boolean          default(TRUE), not null
#  sell_gift_cards    :boolean          default(FALSE), not null
#  owner_image_url    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  target_amount      :integer          default(1000000)
#  hero_image_url     :string
#  progress_bar_color :string
#  business_type      :string
#  num_employees      :integer
#  founded_year       :integer
#  website_url        :string
#  menu_url           :string
#  square_location_id :string           not null
#  cost_per_meal      :integer
#  gallery_image_urls :string           default([]), not null, is an Array
#  logo_image_url     :string
#
class Seller < ApplicationRecord
  # model association
  has_many :locations, dependent: :destroy
  has_many :menu_items, dependent: :destroy
  has_many :delivery_options, dependent: :destroy

  validates_presence_of :seller_id
  validates_presence_of :square_location_id

  validates_inclusion_of :founded_year, in: 1800..2020
  validates_uniqueness_of :seller_id
  validates_uniqueness_of :square_location_id
  validates_inclusion_of :sell_gift_cards, in: [true, false]
  validates_inclusion_of :accept_donations, in: [true, false]
end
