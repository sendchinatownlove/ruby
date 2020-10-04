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
class Nonprofit < ApplicationRecord
end
