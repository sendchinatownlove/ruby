# frozen_string_literal: true

# == Schema Information
#
# Table name: menu_items
#
#  id          :bigint           not null, primary key
#  amount      :decimal(, )
#  description :string
#  image_url   :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  seller_id   :bigint           not null
#
# Indexes
#
#  index_menu_items_on_seller_id  (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (seller_id => sellers.id)
#
class MenuItem < ApplicationRecord
  belongs_to :seller
end
