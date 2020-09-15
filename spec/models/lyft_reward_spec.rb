# frozen_string_literal: true

# == Schema Information
#
# Table name: lyft_rewards
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  expires_at :datetime
#  state      :string           default("new"), not null
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  contact_id :bigint
#
# Indexes
#
#  index_lyft_rewards_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#
require 'rails_helper'

RSpec.describe LyftReward, type: :model do
  it { should belong_to(:contact) }

  it do
    should allow_values('new', 'delivered', 'verified', 'failed')
      .for(:state)
  end
end
