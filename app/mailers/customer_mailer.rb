class CustomerMailer < ApplicationMailer
  def send_receipt
    @payment_intent = params[:payment_intent]
    @url = params[:receipt_url]
    @note = @payment_intent.email_text
    mail(to: @payment_intent.email, subject: 'Receipt from Send Chinatown Love')
  end
end
