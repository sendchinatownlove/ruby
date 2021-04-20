# frozen_string_literal: true

module EmailManager
  class SellerInfoSender < BaseService
    def initialize(params)
      @seller_id = params[:seller_id]
      @seller = Seller.find(@seller_id)
      @merchant_dashboard_link = params[:merchant_dashboard_link]
    end

    def call
      html = <<~EOF
        <!DOCTYPE html>
        <html>
          <head>
            <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
          </head>
          <body>
            <p>Seller</p>
            <p>
              Here is the seller Id for #{seller.name}: #{seller_id}
              <a href="#{merchant_dashboard_link}" target="_blank" rel="noopener norefferrer">
                Merchant Dashboard
              </a>
            </p>
          </body>
        </html>
      EOF
      EmailManager::Sender.send_receipt(
        from: 'receipts@sendchinatownlove.com',
        to: 'receipts@sendchinatownlove.com',
        subject: subject,
        html: html
      )  
    rescue StandardError
      Rails.logger.error 'Seller Info e-mail errored out. ' \
              "email: bvillaroman@gmail.com"
    end
  end
end

