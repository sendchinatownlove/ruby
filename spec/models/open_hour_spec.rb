# frozen_string_literal: true

# == Schema Information
#
# Table name: open_hours
#
#  id         :bigint           not null, primary key
#  close_day  :integer
#  close_time :time
#  open_day   :integer
#  open_time  :time
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
  it { should validate_presence_of(:open_day) }
  it { should validate_presence_of(:close_day) }
  it { should validate_presence_of(:open_time) }
  it { should validate_presence_of(:close_time) }

  it do
    should define_enum_for(:open_day)
  end

  it do
    should define_enum_for(:close_day)
  end
end
