# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id                 :bigint           not null, primary key
#  email              :string
#  seller_id          :bigint           not null
#  item_type          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  payment_intent_id  :bigint           not null
#  refunded           :boolean          default(FALSE)
#  merchant_payout_id :bigint
#
class Item < ApplicationRecord
  belongs_to :seller
  belongs_to :payment_intent
  has_one :gift_card_detail
  has_one :donation_detail
  enum item_type: %i[donation gift_card]
end
