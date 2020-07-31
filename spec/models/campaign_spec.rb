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
#  valid              :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  location_id        :bigint           not null
#  seller_id          :bigint           not null
#
# Indexes
#
#  index_campaigns_on_location_id  (location_id)
#  index_campaigns_on_seller_id    (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (seller_id => sellers.id)
#
require 'rails_helper'

RSpec.describe Campaign, type: :model do
  it { should belong_to(:location) }
  it { should belong_to(:seller) }
end
