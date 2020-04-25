require 'rails_helper'

RSpec.describe Seller, type: :model do
  # Association test
  # ensure Seller model has a 1:m relationship with the MenuItem model
  it { should have_many(:menu_items).dependent(:destroy) }
  # Validation tests

  let!(:seller) do
    create(:seller)
  end

  it "has valid seller_id" do
    should validate_uniqueness_of(:seller_id)
    should validate_presence_of(:seller_id)
  end

  it "has valid square_location_id" do
    should validate_uniqueness_of(:square_location_id)
    should validate_presence_of(:square_location_id)
  end

  it "has valid attributes for sell_gift_cards attribute" do
    should allow_value(%w[true false]).for(:sell_gift_cards)
  end

  it "has valid attributes for accept_donations attributes" do
    should allow_value(%w[true false]).for(:accept_donations)
  end

  it "is valid target_amount" do
    expect(seller.target_amount).to eq 1_000_000
  end

  it "is invalid without seller_id" do
    seller.seller_id = nil
    expect(seller).to_not be_valid
  end

  it "is invalid without square_location_id" do
    seller.square_location_id = nil
    expect(seller).to_not be_valid
  end

  # test founding year constraints
  let(:time_travelling_seller) do
    create(
        :seller,
        founded_year: founded_year,
        )
  end

  context "test pre-1800 founding year" do
    let(:founded_year) { 1 }

    it 'raises an error' do
      expect do
        time_travelling_seller
        # TODO: make this a more informative error message
      end.to raise_error(
                 ActiveRecord::RecordInvalid,
                 'Validation failed: Founded year is not included in the list'
             )
    end
  end

  context "test future founding year" do
    let(:founded_year) { 3000 } # not much has changed but they live underwater

    it 'raises an error' do
      expect do
        time_travelling_seller
        # TODO: make this a more informative error message
      end.to raise_error(
                 ActiveRecord::RecordInvalid,
                 'Validation failed: Founded year is not included in the list'
             )
    end
  end
end
