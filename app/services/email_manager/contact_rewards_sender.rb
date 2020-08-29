# frozen_string_literal: true

module EmailManager
  class ContactRewardsSender < BaseService
    attr_reader :contact_id, :email, :token

    def initialize(params)
      @contact_id = params[:contact_id]
      @email = params[:email]
      @token = params[:token]
    end

    # rubocop:disable Layout/LineLength
    def call
      redemption_url = 'https://merchant.sendchinatownlove.com/passport/' + contact_id.to_s \
        + '/redeem/' + token
      html = <<~EOF
      <!DOCTYPE html>
      <html>
        <head>
          <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
        </head>
        <body>
          <p>Congratulations!</p>
          <p>
            You have unlocked a reward for your participation in the
            <a href="https://www.sendchinatownlove.com/food-crawl.html" target="_blank">
              Send Chinatown Love Food Crawl.
            </a>
          </p>
          <p>
            By visiting our Food Crawl vendors, you can now access a local
            reward to redeem in Chinatown. In the Passport to Chinatown,
            you will be able to view local rewards and redeem them when you
            are at the local rewards partner. <b>Please note that the reward
            must be redeemed in person. Once you click on “Redeem Now” you
            will have 5 minutes to show the vendor host.</b>
          </p>
          <p>
            Click through this unique link to view your available local
            rewards!
          </p>
          <p>
            <i>This link will expire in 30 minutes. You can request a new
            email again if the link expires.</i>
          </p>
          <p>
            <a href="#{redemption_url}" target="_blank">
              <b>MY LOCAL REWARDS</b>
            </a>
          </p>
          <p>(Best viewed on mobile).</p>
        </body>
      </html>
      EOF
      EmailManager::Sender.send_receipt_with_subject(
        to: email,
        html: html,
        subject: "Send Chinatown Love Food Crawl: Redeem Your Reward!",
      )
    rescue StandardError
      Rails.logger.error 'Passport redemption e-mail errored out. ' \
              "email: #{email}"
    end
    # rubocop:enable Layout/LineLength
  end
end
