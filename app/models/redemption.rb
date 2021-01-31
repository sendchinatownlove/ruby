# frozen_string_literal: true

# == Schema Information
#
# Table name: redemptions
#
#  id         :bigint           not null, primary key
#  contact_id :bigint           not null
#  reward_id  :bigint           not null
#
# Indexes
#
#  index_redemptions_on_contact_id  (contact_id)
#  index_redemptions_on_reward_id   (reward_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#  fk_rails_...  (reward_id => rewards.id)
#
class Redemption < ApplicationRecord
  before_destroy :unredeem_receipts
  belongs_to :reward
  belongs_to :contact

  has_many :crawl_receipts

  private

  def unredeem_receipts
    CrawlReceipt.where(redemption_id: self.id).each do |receipt|
      receipt.update_attribute(:redemption_id, nil)
      receipt.save!
    end
  end
end
