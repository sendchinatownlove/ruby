# frozen_string_literal: true
class CustomerMailer < ApplicationMailer
  def send_donation_receipt
    @payment_intent = params[:payment_intent]
    @amount = params[:amount]
    @merchant_name = params[:merchant_name]

    mail(to: @payment_intent.email, subject: 'Receipt from Send Chinatown Love')
  end

  def send_giftcard_receipt
    @payment_intent = params[:payment_intent]
    @amount = params[:amount]
    @merchant_name = params[:merchant_name]
    @receipt_id = params[:receipt_id]

    mail(to: @payment_intent.email, subject: 'Receipt from Send Chinatown Love')
  end
end
