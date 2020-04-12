
class ChargesController < ApplicationController

  # POST /charges
  def create
    # TODO(jtmckibb): This is a secret, shhhh
    Stripe.api_key = 'sk_test_Vux9P2VnjEDHuR4Cg8DHWmhq00y6iKGY8x'

    line_items = charge_params[:line_items].map(&:to_h)
    line_items.each { |item| validate(line_item: item) }
    amount = line_items.inject(0) { |sum, item| sum + item['amount'] * item['quantity'] }

    intent = Stripe::PaymentIntent.create(
      amount: amount,
      currency: 'usd',
      receipt_email: charge_params[:email]
    )

    # Creates a pending PaymentIntent. See webhooks_controller to see what happens
    # when the PaymentIntent is successful.
    PaymentIntent.create!(
      stripe_id: intent['id'],
      email: charge_params[:email],
      line_items: line_items.to_json
    )

    json_response(intent)
  end

  private

  def charge_params
    params.require(:line_items)
    params.require(:email)
    params.permit(:email, line_items: [[:amount, :currency, :item_type, :quantity, :seller_id]])
  end

  def validate(line_item:)
    [:amount, :currency, :item_type, :quantity, :seller_id].each do |attribute|
    unless line_item.key?(attribute)
        raise ActionController::ParameterMissing.new "param is missing or the value is empty: #{attribute}"
      end
    end

    unless ['gift_card', 'donation'].include? line_item['item_type']
      raise InvalidLineItem.new 'line_item must be named `Gift Card` or `Donation`'
    end

    seller_id = line_item['seller_id']
    unless Seller.find_by(seller_id: seller_id).present?
      raise InvalidLineItem.new "Seller does not exist: #{seller_id}"
    end

    unless line_item['amount'].is_a? Integer
      raise InvalidLineItem.new 'line_item.amount must be an Integer'
    end

    unless line_item['quantity'].is_a? Integer
      raise InvalidLineItem.new 'line_item.quantity must be an Integer'
    end

    amount = line_item['amount']
    raise InvalidLineItem.new 'Amount must be at least $0.50 usd' unless amount >= 50
  end
end
