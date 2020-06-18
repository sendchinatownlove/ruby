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
require 'rails_helper'

RSpec.describe DeliveryType, type: :model do
  let!(:delivery_type) do
    create(:delivery_type)
  end

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
