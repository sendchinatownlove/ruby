# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id                :bigint           not null, primary key
#  email             :string
#  item_type         :integer
#  refunded          :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  payment_intent_id :bigint           not null
#  purchaser_id      :bigint
#  seller_id         :bigint           not null
#
# Indexes
#
#  index_items_on_payment_intent_id  (payment_intent_id)
#  index_items_on_purchaser_id       (purchaser_id)
#  index_items_on_seller_id          (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (payment_intent_id => payment_intents.id)
#  fk_rails_...  (purchaser_id => contacts.id)
#  fk_rails_...  (seller_id => sellers.id)
#
require 'rails_helper'

RSpec.describe Item, type: :model do
  it { should have_one(:gift_card_detail) }
  it { should have_one(:donation_detail) }
  it { should belong_to(:purchaser) }
end
