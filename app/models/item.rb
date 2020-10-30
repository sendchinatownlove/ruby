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
class Item < ApplicationRecord
  belongs_to :campaign, optional: true
  belongs_to :payment_intent, optional: true
  belongs_to :purchaser, class_name: 'Contact'

  # Must have seller or project, but not both
  belongs_to :seller, optional: true
  belongs_to :project, optional: true
  validate :has_project_xor_seller?

  enum item_type: %i[donation gift_card]
  has_one :donation_detail
  has_one :gift_card_detail

  private

  def has_project_xor_seller?
    unless project.present? ^ seller.present?
      errors.add(:project, 'Project or Seller must exist, but not both')
      errors.add(:seller, 'Project or Seller must exist, but not both')
    end
  end
end
