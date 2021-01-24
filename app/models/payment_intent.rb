# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_intents
#
#  id                 :bigint           not null, primary key
#  line_items         :text
#  lock_version       :integer
#  metadata           :text
#  receipt_url        :string
#  successful         :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  campaign_id        :bigint
#  fee_id             :bigint
#  project_id         :bigint
#  purchaser_id       :bigint
#  recipient_id       :bigint
#  square_location_id :string           not null
#  square_payment_id  :string           not null
#
# Indexes
#
#  index_payment_intents_on_campaign_id   (campaign_id)
#  index_payment_intents_on_fee_id        (fee_id)
#  index_payment_intents_on_project_id    (project_id)
#  index_payment_intents_on_purchaser_id  (purchaser_id)
#  index_payment_intents_on_recipient_id  (recipient_id)
#
# Foreign Keys
#
#  fk_rails_...  (campaign_id => campaigns.id)
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (purchaser_id => contacts.id)
#  fk_rails_...  (recipient_id => contacts.id)
#
class PaymentIntent < ApplicationRecord
  validates_presence_of :square_payment_id, :square_location_id, if: -> { origin == 'square' }
  validates_uniqueness_of :square_payment_id, allow_nil: true
  has_many :items
  belongs_to :purchaser, class_name: 'Contact'
  belongs_to :recipient, class_name: 'Contact'
  belongs_to :campaign, optional: true
  belongs_to :project, optional: true

  after_create :make_campaign_inactive_if_met_goal

  def amount
    return 0 if line_items.nil?

    line_items_json = JSON.parse(line_items)
    line_items_json.map { |li| li['amount'].to_i }.sum
  end

  # After a payment intent is created, check if the campaign reached its goal.
  # If so, make the campaign inactive
  def make_campaign_inactive_if_met_goal
    campaign = Campaign.find_by(id: self.campaign_id)

    if campaign && campaign.amount_raised >= campaign.target_amount
      campaign.active = false
      campaign.save
    end
  end
end
