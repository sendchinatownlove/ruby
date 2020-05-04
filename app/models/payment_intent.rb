# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_intents
#
#  id                 :bigint           not null, primary key
#  stripe_id          :string
#  email              :string
#  line_items         :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  successful         :boolean          default(FALSE)
#  square_payment_id  :string
#  square_location_id :string
#  email_text         :string
#  receipt_url        :string
#  name               :string
#
class PaymentIntent < ApplicationRecord
  validates_presence_of :square_payment_id, :square_location_id
  validates_uniqueness_of :square_payment_id, allow_nil: false
  has_many :items
end
