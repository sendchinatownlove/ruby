require 'rails_helper'

RSpec.describe GiftCard, type: :model do

  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:charge_id) }
  it { should validate_presence_of(:merchant_id) }
end
