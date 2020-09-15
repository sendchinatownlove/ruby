# frozen_string_literal: true

module EmailManager
  class ContactLyftRewardsSender < BaseService
    attr_reader :contact_id, :email, :token

    def initialize(params)
      @contact_id = params[:contact_id]
      @email = params[:email]
      @token = params[:token]
    end

    # rubocop:disable Layout/LineLength
    def call
      redemption_url = 'https://merchant.sendchinatownlove.com/passport/lyft_rewards' + contact_id.to_s \
        + '/redeem/' + token
      html = <<~EOF
        <!DOCTYPE html>
        <html>
          <head>
            <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
          </head>
          <body>
            <p>
              Hey there! Thanks for participating in the Send Chinatown
              Love food crawl. Below are instructions to redeem your free
              Citi Bike Day Pass:
            </p>
            <p>
              <strong>Citi Bike Day Pass Overview</strong>
              <ul>
                <li>You must be 16 years of age or older to ride a Citi Bike.</li>
                <li>A Day Pass includes unlimited 30-minute rides in a 24-hour period on a classic bike.</li>
                <li>The first 30 minutes of each ride on a classic Citi Bike are included in the pass price.</li>
                <li>When you upgrade your ride to an ebike, it will be an extra $0.15/min.</li>
              </ul>
            </p>
            <p>
              <strong>How to Redeem Your Free Day Pass</strong>
            </p>
            <p>
              A day pass can be redeemed by downloading the free Citi Bike
              app for iPhone or Android.
              <ol>
                <li>Download the Citi Bike app.</li>
                <li>Tap “Choose a Pass” and select “Day Pass.”</li>
                <li>Tap “Continue” and then select “+ Add promo code.”</li>
                <li>Input promo code and click apply.</li>
                <li>Create a Citi Bike account by inputting your email and phone number.</li>
                <li>Create a password.</li>
                <li>Input your name and birthday.</li>
                <li>Agree to the Rental Agreement.</li>
                <li>
                  Input your credit card information (*NOTE: Your credit
                  card will not be charged when redeeming this code. A
                  credit card is needed on file for all Citi Bike
                  memberships to cover any extra time fees.)
                </li>
              </ol>
            </p>
            <p>
              Click through this unique link to view your day pass code!
            </p>
            <p style="font-style: italic">
              This link will expire in 72 hours. You can request a new
              email again if the link expires.
            </p>
            <p>
              <a href="#{redemption_url}" target="_blank">
                <strong>FREE DAY PASS CODE</strong>
              </a>
            </p>
            <p>(Best viewed on mobile).</p>
          </body>
        </html>
      EOF
      EmailManager::Sender.send_receipt(
        to: email,
        html: html,
        subject: 'Send Chinatown Love Food Crawl: Redeem Your Citi Bike Day Pass!'
      )
    rescue StandardError
      Rails.logger.error 'Lyft rewards redemption e-mail errored out. ' \
              "email: #{email}"
    end
    # rubocop:enable Layout/LineLength
  end
  end
