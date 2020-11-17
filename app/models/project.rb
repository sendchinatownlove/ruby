# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id                 :bigint           not null, primary key
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  square_location_id :string           not null
#
class Project < ApplicationRecord
  validates_presence_of :square_location_id

  def amount_raised
    refunded_payment_intent_ids = Refund.where(status: :COMPLETED)
      .map(&:payment_intent_id)
    PaymentIntent.where(project_id: id, successful: true)
      .where.not(id: refunded_payment_intent_ids)
      .map(&:amount).sum
  end
end
