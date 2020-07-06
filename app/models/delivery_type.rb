# frozen_string_literal: true

# == Schema Information
#
# Table name: delivery_types
#
#  id                 :bigint           not null, primary key
#  icon_url           :string
#  name               :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  delivery_option_id :bigint
#
# Indexes
#
#  index_delivery_types_on_delivery_option_id  (delivery_option_id)
#
# Foreign Keys
#
#  fk_rails_...  (delivery_option_id => delivery_options.id)
#
class DeliveryType < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name
end
