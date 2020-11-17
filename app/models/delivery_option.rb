# frozen_string_literal: true

# == Schema Information
#
# Table name: delivery_options
#
#  id               :bigint           not null, primary key
#  phone_number     :string
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  delivery_type_id :bigint           not null
#  seller_id        :bigint           not null
#
# Indexes
#
#  index_delivery_options_on_delivery_type_id  (delivery_type_id)
#  index_delivery_options_on_seller_id         (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (delivery_type_id => delivery_types.id)
#  fk_rails_...  (seller_id => sellers.id)
#
class DeliveryOption < ApplicationRecord
  belongs_to :seller
  belongs_to :delivery_type
end
