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
require 'rails_helper'

RSpec.describe Contact, type: :model do
  it { should validate_uniqueness_of(:email) }
  it { should allow_value(%w(true false)).for(:is_subscribed) }
end
