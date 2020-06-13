# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'gift_cards:create' do
  include_context 'rake'

  QUANTITY = 5
  AMOUNT = 5

  let(:seller) do
    create(:seller)
  end

  let(:distributor) do
    create(:contact)
  end

  it 'seeds gift cards' do
    args = %W[-s #{seller.seller_id} -m #{distributor.email} -q #{QUANTITY} -a #{AMOUNT}]
    stub_const('ARGV', args)
    Rake::Task['gift_cards:create'].invoke
    expect(Item.count).to eq(QUANTITY)
    expect(GiftCardDetail.count).to eq(QUANTITY)
    expect(GiftCardAmount.count).to eq(QUANTITY)

    GiftCardAmount.all.each do |gift_card_amount|
      expect(gift_card_amount.value).to eq(AMOUNT)
    end
  end
end
