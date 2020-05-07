# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :seller
  belongs_to :payment_intent
  belongs_to :gift_card_detail
  has_one :gift_card_detail
  has_one :donation_detail
  enum item_type: %i[donation gift_card]
end
