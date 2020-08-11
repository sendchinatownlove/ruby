# == Schema Information
#
# Table name: sponsor_sellers
#
#  id          :bigint           not null, primary key
#  logo_url    :string
#  name        :string
#  reward      :string
#  reward_cost :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :bigint
#
class SponsorSeller < ApplicationRecord
    validates_presence_of :logo_url, :name, :reward, :reward_cost
end
