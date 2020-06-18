require 'rails_helper'

RSpec.describe DeliveryOption, type: :model do
	it { should have_one(:delivery_type) }
	it { should belong_to(:seller) }
end
