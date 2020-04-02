
class ChargesController < ApplicationController

  # POST /charges
  def create
    # TODO(jtmckibb): This is a secret, shhhh
    Stripe.api_key = 'sk_test_Vux9P2VnjEDHuR4Cg8DHWmhq00y6iKGY8x'

    begin
      merchant_id = charge_params[:merchant_id]
      line_items = charge_params[:line_items].map(&:to_h)

      session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        # TODO(jtmckibb): Validate line items
        #  - Amount should be greater than 1 and needs to be an integer
        #  - Name should be 'Gift Card' or 'Donation'
        #  - Amount, Currency, Name and Quantity are required
        line_items: line_items,
        payment_intent_data: {
          capture_method: 'manual',
        },
        success_url: "https://sendchinatownlove.com/#{merchant_id}/thank-you?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: "https://sendchinatownlove.com/#{merchant_id}/canceled",
        metadata: { merchant_id: merchant_id }
      )
      json_response(session)
    rescue Stripe::StripeError => e
      json_response(e.error.message, e.http_status)
    rescue ActionController::ParameterMissing => e
      json_response(e.message, :unprocessable_entity)
    rescue => e
      json_response(e, :internal_server_error)
    end
  end

  private

  def charge_params
    params.require(:merchant_id)
    params.require(:line_items)
    params.permit(:merchant_id, line_items: [[:amount, :currency, :name, :quantity, :description]])
  end
end
