# frozen_string_literal: true

# == Schema Information
#
# Table name: open_hours
#
#  id         :bigint           not null, primary key
#  close      :time
#  closeday   :integer
#  open       :time
#  openday    :integer
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
  it { should validate_presence_of(:openday) }
  it { should validate_presence_of(:closeday) }
  it { should validate_presence_of(:open) }
  it { should validate_presence_of(:close) }

  it do
    should define_enum_for(:openday)
  end

  it do
    should define_enum_for(:closeday)
  end
end
