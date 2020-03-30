
class ChargesController < ApplicationController

  # POST /charges
  def create
    Stripe.api_key = 'sk_test_Vux9P2VnjEDHuR4Cg8DHWmhq00y6iKGY8x'

    # TODO(jtmckibb): Get merchant name for merchant_id
    merchant_name = charge_params[:merchant_id]
    amount = charge_params[:amount].to_i
    dollars = "%05.2f" % (amount / 100)

    # TODO(jtmckibb): Add Donation Support
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        name: 'Gift Card',
        description: "$#{dollars} Gift Card for #{merchant_name}",
        # TODO(jtmckibb): Add images if we need them
        # images: ['https://example.com/t-shirt.png'],
        amount: amount,
        currency: 'usd',
        quantity: 1,
      }],
      payment_intent_data: {
        capture_method: 'manual',
      },
      # TODO(jtmckibb): Make real URLs
      success_url: 'https://sendchinatownlove.com/charge-sucessful',
      cancel_url: 'https://sendchinatownlove.com/charge-canceled',
    )

    json_response(session)
  end

  private

  def charge_params
    # whitelist params
    params.permit(:merchant_id, :amount, :item)
  end
end
