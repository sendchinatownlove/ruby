require 'rails_helper'

RSpec.describe Seller, type: :model do
  # Association test
  # ensure Seller model has a 1:m relationship with the MenuItem model
  # it { should have_many(:menu_items).dependent(:destroy) }
  # Validation tests
  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:cuisine_name) }
  it { should validate_presence_of(:merchant_name) }
  it { should validate_presence_of(:story) }
  it { should validate_presence_of(:owner_name) }
  it { should validate_presence_of(:owner_url) }
  it { should validate_presence_of(:accept_donations) }
  it { should validate_presence_of(:sell_gift_cards) }
end
