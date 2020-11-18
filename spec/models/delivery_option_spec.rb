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
require 'rails_helper'

RSpec.describe DeliveryOption, type: :model do
  let!(:delivery_option) do
    create(:delivery_option)
  end

  it { should belong_to(:delivery_type) }
  it { should belong_to(:seller) }
end
