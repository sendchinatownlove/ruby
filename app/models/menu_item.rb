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
class MenuItem < ApplicationRecord
  belongs_to :seller
end
