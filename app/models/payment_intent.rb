# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_intents
#
#  id                 :bigint           not null, primary key
#  line_items         :text
#  lock_version       :integer
#  receipt_url        :string
#  successful         :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  campaign_id        :bigint
#  fee_id             :bigint
#  purchaser_id       :bigint
#  recipient_id       :bigint
#  square_location_id :string           not null
#  square_payment_id  :string           not null
#
# Indexes
#
#  index_payment_intents_on_campaign_id   (campaign_id)
#  index_payment_intents_on_fee_id        (fee_id)
#  index_payment_intents_on_purchaser_id  (purchaser_id)
#  index_payment_intents_on_recipient_id  (recipient_id)
#
# Foreign Keys
#
#  fk_rails_...  (campaign_id => campaigns.id)
#  fk_rails_...  (purchaser_id => contacts.id)
#  fk_rails_...  (recipient_id => contacts.id)
#
class PaymentIntent < ApplicationRecord
  validates_presence_of :square_payment_id, :square_location_id
  validates_uniqueness_of :square_payment_id, allow_nil: false
  has_many :items
  belongs_to :purchaser, class_name: 'Contact'
  belongs_to :recipient, class_name: 'Contact'
  belongs_to :campaign, optional: true
end
