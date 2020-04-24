class CustomerMailer < ApplicationMailer
  def send_receipt
    @payment_intent = params[:payment_intent]

    mail(to: @payment_intent.email, subject: 'Receipt from Send Chinatown Love')
  end
end
