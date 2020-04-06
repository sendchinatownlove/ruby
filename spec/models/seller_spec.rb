require 'rails_helper'

RSpec.describe Seller, type: :model do
  # Association test
  # ensure Seller model has a 1:m relationship with the MenuItem model
  # it { should have_many(:menu_items).dependent(:destroy) }
  # Validation tests
  subject { Seller.create(url: 'oiawjefoiwjaef') }
  it { should validate_uniqueness_of(:url) }
  it do
    should allow_value(%w[true false]).for(:sell_gift_cards)
  end
  it do
    should allow_value(%w[true false]).for(:accept_donations)
  end
end
