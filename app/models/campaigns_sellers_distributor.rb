# frozen_string_literal: true

# == Schema Information
#
# Table name: campaigns_sellers_distributors
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  campaign_id    :bigint           not null
#  distributor_id :bigint           not null
#  seller_id      :bigint           not null
#
# Indexes
#
#  campaigns_sellers_distributors_unique                   (campaign_id,distributor_id,seller_id) UNIQUE
#  index_campaigns_sellers_distributors_on_campaign_id     (campaign_id)
#  index_campaigns_sellers_distributors_on_distributor_id  (distributor_id)
#  index_campaigns_sellers_distributors_on_seller_id       (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (campaign_id => campaigns.id)
#  fk_rails_...  (distributor_id => distributors.id)
#  fk_rails_...  (seller_id => sellers.id)
#
class CampaignsSellersDistributor < ApplicationRecord
  belongs_to :campaign
  belongs_to :seller
  belongs_to :distributor
end
