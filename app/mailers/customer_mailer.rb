class CustomerMailer < ApplicationMailer
  def send_receipt
    @payment_intent = params[:payment_intent]
    @url = @payment_intent.receipt_url
    @note = @payment_intent.email_text
    @customer_name = params[:customer_name]

    mail(to: @payment_intent.email, subject: 'Receipt from Send Chinatown Love')
  end
end
