# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id                              :bigint           not null, primary key
#  email                           :string           not null
#  instagram                       :string
#  is_subscribed                   :boolean          default(TRUE), not null
#  name                            :string
#  rewards_redemption_access_token :string
#
# Indexes
#
#  index_contacts_on_email  (email) UNIQUE
#
require 'rails_helper'

RSpec.describe Contact, type: :model do
  before { create :contact }
  it { should validate_uniqueness_of(:email) }
  it { should allow_value(%w[true false]).for(:is_subscribed) }
  it { should have_many(:items) }
  it { should have_many(:gift_card_details) }
end
