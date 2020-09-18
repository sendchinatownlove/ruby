# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id                              :bigint           not null, primary key
#  email                           :string           not null
#  expires_at                      :datetime
#  instagram                       :string
#  is_subscribed                   :boolean          default(TRUE), not null
#  name                            :string
#  rewards_redemption_access_token :string
#
# Indexes
#
#  index_contacts_on_email  (email) UNIQUE
#
require 'rails_helper'

RSpec.describe Contact, type: :model do
  before do
    @contact = create :contact
    @lyft_reward = create :lyft_reward
  end

  it { should validate_uniqueness_of(:email) }
  it { should allow_value(%w[true false]).for(:is_subscribed) }
  it { should have_many(:items) }
  it { should have_many(:gift_card_details) }

  context 'has_redeemed_lyft_reward' do
    context 'with an unverified reward' do
      context 'with no reward assigned to the contact' do
        it 'should return false' do
          expect(@contact.has_redeemed_lyft_reward).to eq(false)
        end
      end

      context 'with a delivered reward' do
        before do
          @lyft_reward.update(
            state: 'delivered',
            contact: @contact
          )
        end

        it 'should return false' do
          expect(@contact.has_redeemed_lyft_reward).to eq(false)
        end
      end
    end

    context 'with a verified reward' do
      before do
        @lyft_reward.update(
          state: 'verified',
          contact: @contact
        )
      end

      it 'should return true' do
        expect(@contact.has_redeemed_lyft_reward).to eq(true)
      end
    end
  end

  context 'is_eligible_for_lyft_reward' do
    context 'when the contact has already redeemed a reward' do
      before do
        @lyft_reward.update(
          state: 'verified',
          contact: @contact
        )
      end

      it 'should return false' do
        expect(@contact.is_eligible_for_lyft_reward).to eq(false)
      end
    end

    context 'when the contact has not redeemed a ticket from a lyft sponsored participating seller' do
      before do
        @lyft_reward.update(
          state: 'delivered',
          contact: @contact
        )
        participating_seller = create(
          :participating_seller,
          is_lyft_sponsored: false
        )
        ticket = create(
          :ticket,
          contact: @contact,
          participating_seller: participating_seller
        )
      end

      it 'should return false' do
        expect(@contact.is_eligible_for_lyft_reward).to eq(false)
      end
    end

    context 'when the contact has redeemed a ticket from a lyft sponsored participating seller' do
      before do
        participating_seller = create(
          :participating_seller,
          is_lyft_sponsored: true
        )
        ticket = create(
          :ticket,
          contact: @contact,
          participating_seller: participating_seller,
        )
      end

      context 'when there is a new reward' do
        before do
          @lyft_reward.update(
            state: 'new'
          )
        end

        it 'should return true' do
          expect(@contact.is_eligible_for_lyft_reward).to eq(true)
        end
      end

      context 'when the contact has a delivered reward' do
        before do
          @lyft_reward.update(
            state: 'delivered'
          )
        end

        context 'when the reward has expired' do
          before do
            @lyft_reward.update(
              expires_at: Date.today - 1.days
            )
          end

          it 'should return true' do
            expect(@contact.is_eligible_for_lyft_reward).to eq(true)
          end
        end

        context 'when the reward has not expired' do
          before do
            @lyft_reward.update(
              expires_at: Date.today + 1.days
            )
          end

          it 'should return false' do
            expect(@contact.is_eligible_for_lyft_reward).to eq(false)
          end
        end
      end
    end
  end
end
