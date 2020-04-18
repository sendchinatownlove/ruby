class SellerExtraInfo < ApplicationRecord
  belongs_to :seller
  validates_inclusion_of :founded, :in => 1800..2020
end
