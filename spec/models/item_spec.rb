# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id                :bigint           not null, primary key
#  item_type         :integer
#  refunded          :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  campaign_id       :bigint
#  payment_intent_id :bigint
#  project_id        :bigint
#  purchaser_id      :bigint
#  seller_id         :bigint
#
# Indexes
#
#  index_items_on_campaign_id        (campaign_id)
#  index_items_on_payment_intent_id  (payment_intent_id)
#  index_items_on_project_id         (project_id)
#  index_items_on_purchaser_id       (purchaser_id)
#  index_items_on_seller_id          (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (campaign_id => campaigns.id)
#  fk_rails_...  (payment_intent_id => payment_intents.id)
#  fk_rails_...  (purchaser_id => contacts.id)
#  fk_rails_...  (seller_id => sellers.id)
#
require 'rails_helper'

RSpec.describe Item, type: :model do
  it { should have_one(:gift_card_detail) }
  it { should have_one(:donation_detail) }

  let!(:project) do
    create :project
  end

  context 'when creating an item with only a project' do
    let(:item) do
      create(:item, seller: nil, project: project)
    end

    it 'is successful' do
      item
    end
  end

  context 'when creating an item with only a seller' do
    let(:item) do
      # factory associates a seller by default
      create :item
    end

    it 'is successful' do
      item
    end
  end

  context 'when creating an item with neither a project nor a seller' do
    let(:item) do
      Item.create(project: nil, seller: nil)
    end

    subject { item }

    it 'throws an error' do
      expect(subject).to_not be_valid

      expect(subject.errors[:project]).to include('Project or Seller must exist')
      expect(subject.errors[:seller]).to include('Project or Seller must exist')
    end
  end
end
