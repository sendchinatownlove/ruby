require 'rails_helper'

RSpec.describe SellerExtraInfo, type: :model do
  let(:seller_extra_info1) do
    create(
      :seller_extra_info,
      seller: seller1
    )
  end

  it 'sucessfully creates' do
    expect { seller_extra_info1.should belong_to(:seller) }
  end
end
