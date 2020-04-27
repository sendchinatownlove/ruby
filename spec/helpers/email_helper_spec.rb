# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailHelper, type: :helper do
  describe '#format_sellers_as_list' do
    context 'with one seller' do
      let(:sellers) { ['Taco Kitchen'] }

      it 'returns the list of sellers with `and`' do
        expect(EmailHelper.format_sellers_as_list(seller_names: sellers))
          .to eq('Taco Kitchen')
      end
    end

    context 'with two sellers' do
      let(:sellers) { ['Taco Kitchen', 'Dumpling Town'] }

      it 'returns the list of sellers with `and`' do
        expect(EmailHelper.format_sellers_as_list(seller_names: sellers))
          .to eq('Dumpling Town, and Taco Kitchen')
      end
    end

    context 'with many sellers' do
      let(:sellers) { ['Taco Kitchen', 'Dumpling Town', 'Everlane', 'TikTok'] }

      it 'returns the list of sellers with `and`' do
        expect(EmailHelper.format_sellers_as_list(seller_names: sellers))
          .to eq('Dumpling Town, Everlane, Taco Kitchen, and TikTok')
      end
    end
  end
end
