require 'rails_helper'

RSpec.describe 'Webhooks API', type: :request do
  before { freeze_time }
  let(:current_time) { Time.current.utc.iso8601(3).to_s }

  # Test suite for POST /webhooks
  describe 'POST /webhooks' do
    let(:customer) { { 'id': 'justin_mckibben' } }
    let(:seller_id) { Seller.last['seller_id'] }
    let(:session) do
      {
        'customer': customer,
        'customer_email': nil,
        'display_items': [
          {
            'amount': 5000,
            'currency': 'usd',
            'custom': {
              'description': '$50.00 donation to Shunfa Bakery',
              'images': nil,
              'name': item_name
            },
            'quantity': 1,
            'type': 'custom'
          }
        ],
        'metadata': {
          'merchant_id': seller_id
        },
      }
    end

    let(:payload) do
      {
        'type': 'checkout.session.completed',
        'data': {
          'object': session
        }
      }
    end

    before do
      create :seller
      allow(Stripe::Webhook).to receive(:construct_event)
        .and_return(payload.with_indifferent_access)
      post '/webhooks'
    end

    context 'with donation' do
      let(:item_name) { 'Donation' }

      it 'creates a Donation' do
        donation_detail = DonationDetail.last
        expect(donation_detail).not_to be_nil
        expect(donation_detail['amount']).to eq(5000)
        item = Item.find(donation_detail['item_id'])
        expect(item).not_to be_nil
        expect(item['stripe_customer_id']).to eq('justin_mckibben')
        # DONATION ENUM
        # TODO(jtmckibb): Update this to import the actual ENUM
        expect(item['item_type']).to eq(0)
        seller = Seller.find_by(seller_id: seller_id)
        expect(item.seller).to eq(seller)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end
end
