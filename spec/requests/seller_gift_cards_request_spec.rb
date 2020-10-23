# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SellerGiftCards', type: :request do
  context 'GET /sellers/:seller_id/gift_cards/:id' do
    let!(:seller) { create :seller }

    context 'with gift cards' do
      let!(:contact1) do
        create :contact
      end
      let!(:contact2) do
        create :contact
      end
      let!(:contact3) do
        create :contact
      end

      let!(:gift_card1) do
        create_gift_card refunded: false, contact: contact1, seller: seller, single_use: false
      end

      let!(:gift_card2) do
        create_gift_card refunded: false, contact: contact2, seller: seller, single_use: false
      end

      let!(:refunded_gift_card) do
        create_gift_card refunded: true, contact: contact2, seller: seller, single_use: false
      end

      let!(:gift_cardGAM) do
        create_gift_card refunded: false, contact: contact3, seller: seller, single_use: true
      end

      let!(:gift_card_for_another_seller) do
        create_gift_card(
          refunded: false,
          contact: contact1,
          seller: create(:seller),
          single_use: false
        )
      end

      let(:expected_gift_card_latest_amount) { 30_00 }
      let(:expected_gift_card_original_amount) { 10_00 }
      let(:expected_gift_card_last_updated) { Time.current + 1.day }

      def create_gift_card(refunded:, contact:, seller:, single_use:)
        item = create(:item, refunded: refunded, seller: seller)
        gift_card_detail = create(
          :gift_card_detail,
          item: item,
          recipient: contact,
          single_use: single_use
        )
        # the original amount, which matters
        create(
          :gift_card_amount,
          value: expected_gift_card_original_amount,
          gift_card_detail: gift_card_detail
        )
        create(
          :gift_card_amount,
          gift_card_detail: gift_card_detail
        )
        # The latest amount, which matters
        create(
          :gift_card_amount,
          value: expected_gift_card_latest_amount,
          gift_card_detail: gift_card_detail,
          updated_at: expected_gift_card_last_updated
        )
        create(
          :gift_card_amount,
          gift_card_detail: gift_card_detail
        )
        gift_card_detail
      end

      def expected_gift_card_json(gift_card_detail:, contact:)
        {
          gift_card_id: gift_card_detail.gift_card_id,
          seller_gift_card_id: gift_card_detail.seller_gift_card_id,
          latest_value: expected_gift_card_latest_amount,
          original_value: expected_gift_card_original_amount,
          name: contact.name,
          email: contact.email,
          created_at: gift_card_detail.created_at.utc,
          expiration: gift_card_detail.expiration,
          single_use: gift_card_detail.single_use,
          updated_at: gift_card_detail.updated_at.utc,
          last_updated: expected_gift_card_last_updated,
        }.as_json
      end

      context 'with valid seller_id' do
        before { get "/sellers/#{seller_id}/gift_cards/#{gift_cards_access_token}" }
        let(:seller_id) { seller.seller_id }

        context 'with valid gift_cards_access_token' do
          let(:gift_cards_access_token) { seller.gift_cards_access_token }

          it 'returns all the gift cards except the refunded one' do
            expect(json).not_to be_empty
            expect(json.size).to eq 3
            expect(json).to eq(
              [
                expected_gift_card_json(
                  gift_card_detail: gift_card1,
                  contact: contact1
                ),
                expected_gift_card_json(
                  gift_card_detail: gift_card2,
                  contact: contact2
                ),
                expected_gift_card_json(
                  gift_card_detail: gift_cardGAM,
                  contact: contact3
                )
              ]
            )
          end

          it 'returns 200' do
            expect(response).to have_http_status(200)
          end
        end

        context 'with invalid gift_cards_access_token' do
          let(:gift_cards_access_token) { 'blahblahblah' }

          it 'returns 404' do
            expect(response).to have_http_status(404)
          end
        end
      end

      context 'with filtering GAM' do
        before { get "/sellers/#{seller_id}/gift_cards/#{gift_cards_access_token}?filterGAM=true" }
        let(:seller_id) { seller.seller_id }
        let(:gift_cards_access_token) { seller.gift_cards_access_token }

        it 'returns all the gift cards except the refunded and the GAM one' do
          expect(json).not_to be_empty
          expect(json.size).to eq 2
          expect(json).to eq(
            [
              expected_gift_card_json(
                gift_card_detail: gift_card1,
                contact: contact1
              ),
              expected_gift_card_json(
                gift_card_detail: gift_card2,
                contact: contact2
              )
            ]
          )
        end

        it 'returns 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'with invalid seller_id' do
        before { get "/sellers/#{seller_id}/gift_cards/#{gift_cards_access_token}" }
        let(:seller_id) { 'blahblahblah' }
        let(:gift_cards_access_token) { seller.gift_cards_access_token }

        it 'returns 404' do
          expect(response).to have_http_status(404)
        end
      end
    end

    context 'without gift cards' do
      before { get "/sellers/#{seller.seller_id}/gift_cards/#{seller.gift_cards_access_token}" }

      it 'returns empty array' do
        expect(json).to be_empty
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end
    end
  end
end
