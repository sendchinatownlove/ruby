# == Schema Information
#
# Table name: contacts
#
#  id                   :bigint           not null, primary key
#  email                :string
#  is_subscribed        :boolean          default(TRUE), not null
#  name                 :string
#  gift_card_details_id :bigint
#  items_id             :bigint
#  payment_intents_id   :bigint
#
# Indexes
#
#  index_contacts_on_email                 (email)
#  index_contacts_on_gift_card_details_id  (gift_card_details_id)
#  index_contacts_on_items_id              (items_id)
#  index_contacts_on_payment_intents_id    (payment_intents_id)
#
class Contact < ApplicationRecord
  validates_uniqueness_of :email, :allow_blank => true, :allow_nil => true
  validates :is_subscribed, inclusion: { in: [ true, false ] }
  has_many :payment_intent
  has_many :item
  has_many :gift_card_detail
end
