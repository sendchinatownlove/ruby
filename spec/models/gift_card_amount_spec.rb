# frozen_string_literal: true

# == Schema Information
#
# Table name: gift_card_amounts
#
#  id                  :bigint           not null, primary key
#  value               :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  gift_card_detail_id :bigint           not null
#
# Indexes
#
#  index_gift_card_amounts_on_gift_card_detail_id  (gift_card_detail_id)
#
# Foreign Keys
#
#  fk_rails_...  (gift_card_detail_id => gift_card_details.id)
#
require 'rails_helper'

RSpec.describe GiftCardAmount, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
