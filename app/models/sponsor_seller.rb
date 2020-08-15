# frozen_string_literal: true

# == Schema Information
#
# Table name: sponsor_sellers
#
#  id          :bigint           not null, primary key
#  logo_url    :string
#  name        :string
#  reward      :string
#  reward_cost :integer          default(3), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :bigint
#
class SponsorSeller < ApplicationRecord
  validates_presence_of :reward_cost
end
