require 'rails_helper'

RSpec.describe Seller, type: :model do
  # Association test
  # ensure Seller model has a 1:m relationship with the MenuItem model
  it { should have_many(:menu_items).dependent(:destroy) }
  # Validation tests

  let!(:seller) do
    create(:seller)
  end
  it { should validate_uniqueness_of(:seller_id) }
  it do
    should allow_value(%w[true false]).for(:sell_gift_cards)
  end
  it do
    should allow_value(%w[true false]).for(:accept_donations)
  end
  it { expect(seller.target_amount).to eq 1_000_000 }

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
