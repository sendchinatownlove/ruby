# frozen_string_literal: true

# == Schema Information
#
# Table name: rewards
#
#  id          :bigint           not null, primary key
#  image_url   :string
#  name        :string
#  total_value :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Reward < ApplicationRecord
end
