# frozen_string_literal: true

# == Schema Information
#
# Table name: donation_details
#
#  id         :bigint           not null, primary key
#  item_id    :bigint           not null
#  amount     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe DonationDetail, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
