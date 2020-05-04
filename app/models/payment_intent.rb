# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_intents
#
#  id                 :bigint           not null, primary key
#  email              :string
#  email_text         :string
#  line_items         :text
#  name               :string
#  receipt_url        :string
#  successful         :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  square_location_id :string           not null
#  square_payment_id  :string           not null
#
class PaymentIntent < ApplicationRecord
  validates_presence_of :square_payment_id, :square_location_id
  validates_uniqueness_of :square_payment_id, allow_nil: false
  has_many :items
end
