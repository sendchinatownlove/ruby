# ActionMailer::Base.smtp_settings = {
#     :port           => ENV['MAILGUN_SMTP_PORT'],
#     :address        => ENV['MAILGUN_SMTP_SERVER'],
#     :user_name      => ENV['MAILGUN_SMTP_LOGIN'],
#     :password       => ENV['MAILGUN_SMTP_PASSWORD'],
#     :domain         => 'sendchinatownlove.herokuapp.com',
#     :authentication => :plain,
#     enable_starttls_auto: true,
# }
ActionMailer::Base.smtp_settings = {
    :port           => 587,
    :address        => "smtp.mailgun.org",
    :user_name      => "postmaster@sandbox6657e75f5d664a16921d418cd676ac5c.mailgun.org",
    :password       => "69cac0b97a813a000fd8d198c596bfab-f135b0f1-ce7a2435",
    :domain         => 'sendchinatownlove.herokuapp.com',
    :authentication => :plain,
}
ActionMailer::Base.delivery_method = :smtp
