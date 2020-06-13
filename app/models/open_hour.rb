# == Schema Information
#
# Table name: open_hours
#
#  id         :bigint           not null, primary key
#  close      :time
#  day        :integer
#  open       :time
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  seller_id  :bigint           not null
#
# Indexes
#
#  index_open_hours_on_seller_id  (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (seller_id => sellers.id)
#
class OpenHour < ApplicationRecord
  belongs_to :seller
  validates_presence_of :day, :closes, :opens
  validates_inclusion_of :day, :in => 1..7
  validate :opens_before_closes 


  protected
  def opens_before_closes
    errors.add(:closes, I18n.t('errors.opens_before_closes')) if opens && closes && opens >= closes
  end
end
