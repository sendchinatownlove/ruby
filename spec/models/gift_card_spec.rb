require 'rails_helper'

RSpec.describe GiftCard, type: :model do

  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:charge_id) }
  it { should validate_uniqueness_of(:charge_id)}

  it { should validate_presence_of(:merchant_id) }
  it { should validate_presence_of(:customer_id)}
end
