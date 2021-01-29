# frozen_string_literal: true

# == Schema Information
#
# Table name: participating_sellers
#
#  id                :bigint           not null, primary key
#  active            :boolean
#  is_lyft_sponsored :boolean          default(FALSE)
#  name              :string
#  stamp_url         :string
#  tickets_secret    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  seller_id         :bigint
#
class ParticipatingSeller < ApplicationRecord
  validates_presence_of :name

  before_create :set_tickets_secret

  def set_tickets_secret
    self.tickets_secret = generate_tickets_secret
  end

  def generate_tickets_secret
    loop do
      secret = SecureRandom.uuid
      unless ParticipatingSeller.where(tickets_secret: secret).exists?
        break secret
      end
    end
  end
end
