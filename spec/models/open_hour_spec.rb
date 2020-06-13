# frozen_string_literal: true

# == Schema Information
#
# Table name: open_hours
#
#  id         :bigint           not null, primary key
#  close      :time
#  day        :integer
#  open       :time
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  seller_id  :bigint           not null
#
# Indexes
#
#  index_open_hours_on_seller_id  (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (seller_id => sellers.id)
#
require 'rails_helper'

RSpec.describe OpenHour, type: :model do
  it { should belong_to(:seller) }
end
