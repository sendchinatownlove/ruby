# frozen_string_literal: true

# == Schema Information
#
# Table name: redemptions
#
#  id         :bigint           not null, primary key
#  contact_id :bigint           not null
#  reward_id  :bigint           not null
#
# Indexes
#
#  index_redemptions_on_contact_id  (contact_id)
#  index_redemptions_on_reward_id   (reward_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#  fk_rails_...  (reward_id => rewards.id)
#
require 'rails_helper'

RSpec.describe Redemption, type: :model do
  it { should belong_to(:contact) }
  it { should belong_to(:reward) }
  it { should have_many(:crawl_receipts) }

  describe '#unredeem_receipts' do
    let!(:contact) { create(:contact) }
    let!(:reward) { create(:reward) }
    let!(:redemption) { create(:redemption, contact: contact, reward: reward) }
    let!(:crawl_receipt1) { create(:crawl_receipt, :with_payment_intent, redemption: redemption) }
    let!(:crawl_receipt2) { create(:crawl_receipt, :with_payment_intent, redemption: redemption) }
    let!(:crawl_receipt3) { create(:crawl_receipt, :with_payment_intent, redemption: redemption) }

    it 'unredeems the receipts when the redemption is destroyed' do
      redemption.destroy!
      expect(crawl_receipt1.reload.redemption_id).to eq(nil)
      expect(crawl_receipt2.reload.redemption_id).to eq(nil)
      expect(crawl_receipt3.reload.redemption_id).to eq(nil)
    end
  end
end
