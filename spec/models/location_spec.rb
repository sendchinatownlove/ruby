# frozen_string_literal: true

# == Schema Information
#
# Table name: locations
#
#  id           :bigint           not null, primary key
#  address1     :string           not null
#  address2     :string
#  city         :string           not null
#  state        :string           not null
#  zip_code     :string           not null
#  seller_id    :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  phone_number :string
#
require 'rails_helper'

RSpec.describe Location, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
