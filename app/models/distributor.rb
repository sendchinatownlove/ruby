# frozen_string_literal: true

# == Schema Information
#
# Table name: distributors
#
#  id                         :bigint           not null, primary key
#  gift_card_login_expires_at :datetime
#  gift_card_login_state      :string           default("new"), not null
#  gift_card_login_token      :string
#  image_url                  :string
#  name                       :string
#  website_url                :string
#  contact_id                 :bigint
#
# Indexes
#
#  index_distributors_on_contact_id  (contact_id)
#
class Distributor < ApplicationRecord
  belongs_to :contact
end
