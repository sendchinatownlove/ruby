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
#  purchaser_id      :bigint
#  seller_id         :bigint           not null
#
# Indexes
#
#  index_items_on_campaign_id        (campaign_id)
#  index_items_on_payment_intent_id  (payment_intent_id)
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
  belongs_to :seller
  enum item_type: %i[donation gift_card]
  has_one :donation_detail
  has_one :gift_card_detail
end
