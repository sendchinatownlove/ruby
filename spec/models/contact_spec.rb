# == Schema Information
#
# Table name: contacts
#
#  id            :bigint           not null, primary key
#  email         :string
#  is_subscribed :boolean          default(TRUE), not null
#  name          :string
#
# Indexes
#
#  index_contacts_on_email  (email)
#
require 'rails_helper'

RSpec.describe Contact, type: :model do
  it { should validate_uniqueness_of(:email) }
  it { should allow_value(%w(true false)).for(:is_subscribed) }
  it { should have_many(:items) }
  it { should have_many(:gift_card_details) }
end
