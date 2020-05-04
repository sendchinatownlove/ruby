# frozen_string_literal: true

# == Schema Information
#
# Table name: donation_details
#
#  id         :bigint           not null, primary key
#  amount     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  item_id    :bigint           not null
#
# Indexes
#
#  index_donation_details_on_item_id  (item_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => items.id)
#
require 'rails_helper'

RSpec.describe DonationDetail, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
