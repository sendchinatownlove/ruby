# frozen_string_literal: true

# == Schema Information
#
# Table name: nonprofits
#
#  id             :bigint           not null, primary key
#  logo_image_url :string
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  contact_id     :integer
#  fee_id         :integer
#
require 'rails_helper'

RSpec.describe Nonprofit, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
