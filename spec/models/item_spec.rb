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
require 'rails_helper'

RSpec.describe Item, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
