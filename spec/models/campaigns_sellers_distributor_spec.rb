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
require 'rails_helper'

RSpec.describe CampaignsSellersDistributor, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
