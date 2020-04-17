require 'rails_helper'

RSpec.describe Seller, type: :model do
  # Association test
  # ensure Seller model has a 1:m relationship with the MenuItem model
  it { should have_many(:menu_items).dependent(:destroy) }
  # Validation tests
  let!(:seller) { Seller.create(seller_id: 'oiawjefoiwjaef') }
  it { should validate_uniqueness_of(:seller_id) }
  it do
    should allow_value(%w[true false]).for(:sell_gift_cards)
  end
  it do
    should allow_value(%w[true false]).for(:accept_donations)
  end
  it { expect(seller.target_amount).to eq 1_000_000 }
  it { expect(seller.accept_donations).to eq true }
  it { expect(seller.sell_gift_cards).to eq false }
end
