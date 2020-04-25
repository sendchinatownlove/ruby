ActionMailer::Base.smtp_settings = {
    :port           => ENV['MAILGUN_SMTP_PORT'],
    :address        => ENV['MAILGUN_SMTP_SERVER'],
    :user_name      => ENV['MAILGUN_SMTP_LOGIN'],
    :password       => ENV['MAILGUN_SMTP_PASSWORD'],
    :domain         => 'sandbox74151aabc4114674a95154526cf10e4f.mailgun.org',
    :authentication => :plain,
}
ActionMailer::Base.delivery_method = :smtp

class CustomerMailer < ApplicationMailer
  default from: "receipts@sendchinatownlove.com"

  def send_receipt
    @payment_intent = params[:payment_intent]
    mail(to: @payment_intent.email, subject: 'Receipt from Send Chinatown Love')
  end

end
