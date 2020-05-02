class MerchantPayout < ApplicationRecord
  enum payout_type: [:check, :cash] # default is check
  has_many :items
  belongs_to :seller

  validates_presence_of :payout_type, :total_amount, :account_number
  validates_numericality_of :total_amount, :account_number
  validates_associated :items
end
