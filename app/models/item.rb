# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id                :bigint           not null, primary key
#  amount            :decimal(, )      not null
#  email             :string
#  item_type         :integer
#  refunded          :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  payment_intent_id :bigint           not null
#  seller_id         :bigint           not null
#
# Indexes
#
#  index_items_on_payment_intent_id  (payment_intent_id)
#  index_items_on_seller_id          (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (payment_intent_id => payment_intents.id)
#  fk_rails_...  (seller_id => sellers.id)
#
class Item < ApplicationRecord
  belongs_to :seller
  belongs_to :payment_intent
  has_one :gift_card_detail
  has_one :donation_detail
  enum item_type: %i[donation gift_card]
end
