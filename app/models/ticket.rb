# frozen_string_literal: true

# == Schema Information
#
# Table name: tickets
#
#  id                      :bigint           not null, primary key
#  expiration              :date
#  redeemed_at             :date
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  contact_id              :bigint           not null
#  participating_seller_id :bigint           not null
#  sponsor_seller_id       :bigint
#  ticket_id               :string
#
# Indexes
#
#  index_tickets_on_contact_id               (contact_id)
#  index_tickets_on_participating_seller_id  (participating_seller_id)
#  index_tickets_on_sponsor_seller_id        (sponsor_seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#  fk_rails_...  (participating_seller_id => participating_sellers.id)
#  fk_rails_...  (sponsor_seller_id => sponsor_sellers.id)
#
class Ticket < ApplicationRecord
  belongs_to :contact
  belongs_to :participating_seller
  belongs_to :sponsor_seller, optional: true

  validates_presence_of :ticket_id, :participating_seller_id
  validates_uniqueness_of :ticket_id
end
