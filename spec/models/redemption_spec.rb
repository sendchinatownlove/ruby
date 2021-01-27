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
require 'rails_helper'

RSpec.describe Redemption, type: :model do
  it { should belong_to(:contact) }
  it { should belong_to(:reward) }
end
