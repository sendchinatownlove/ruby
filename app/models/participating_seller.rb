# frozen_string_literal: true

# == Schema Information
#
# Table name: participating_sellers
#
#  id             :bigint           not null, primary key
#  name           :string
#  stamp_url      :string
#  tickets_secret :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  seller_id      :bigint
#
class ParticipatingSeller < ApplicationRecord
  validates_presence_of :name
end
