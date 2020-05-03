# frozen_string_literal: true

ActionMailer::Base.smtp_settings = {
  port: ENV['MAILGUN_SMTP_PORT'],
  address: ENV['MAILGUN_SMTP_SERVER'],
  user_name: ENV['MAILGUN_SMTP_LOGIN'],
  password: ENV['MAILGUN_SMTP_PASSWORD'],
  domain: 'm.sendchinatownlove.com',
  authentication: :plain
}
ActionMailer::Base.delivery_method = :smtp

class ApplicationMailer < ActionMailer::Base
  default from: 'receipts@sendchinatownlove.com'
  layout 'mailer'
end
