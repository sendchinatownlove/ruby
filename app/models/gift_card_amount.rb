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
class GiftCardAmount < ApplicationRecord
  belongs_to :gift_card_detail

  def self.latest_amounts_sql
    GiftCardAmount
      .select('distinct on (gift_card_detail_id) *')
      .order(:gift_card_detail_id, created_at: :desc)
      .to_sql
  end

  def self.original_amounts_sql
    GiftCardAmount
      .select('distinct on (gift_card_detail_id) *')
      .order(:gift_card_detail_id, created_at: :asc)
      .to_sql
  end
end
