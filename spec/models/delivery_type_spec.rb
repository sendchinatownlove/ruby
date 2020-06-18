require 'rails_helper'

RSpec.describe DeliveryType, type: :model do
  let!(:delivery_type) do
    create(:delivery_type)
  end

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
