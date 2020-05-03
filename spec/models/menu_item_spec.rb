# frozen_string_literal: true

# == Schema Information
#
# Table name: menu_items
#
#  id          :bigint           not null, primary key
#  name        :string
#  description :string
#  amount      :decimal(, )
#  image_url   :string
#  seller_id   :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  it { should belong_to(:seller) }
end
