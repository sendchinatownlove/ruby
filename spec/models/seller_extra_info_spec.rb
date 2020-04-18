require 'rails_helper'

RSpec.describe SellerExtraInfo, type: :model do
  it { should belong_to(:seller) }
end
