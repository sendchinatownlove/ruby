require 'rails_helper'

RSpec.describe DeliveryOption, type: :model do
	let!(:delivery_option) do
		create(:delivery_option)
	end

	it { should have_one(:delivery_type) }
	it { should belong_to(:seller) }
end
