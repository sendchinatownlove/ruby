# frozen_string_literal: true

# == Schema Information
#
# Table name: delivery_types
#
#  id               :bigint           not null, primary key
#  icon_url         :string
#  name             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  delivery_type_id :string
#
class DeliveryType < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name
end
