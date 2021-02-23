# frozen_string_literal: true

module EmailManager
  class LnyCrawlRedemptionSender < BaseService
    def initialize(params)
      @contact_id = params[:contact_id]
      @contact = Contact.find(@contact_id)
      @email = @contact.email
    end

    def call
      entry_details = "<p><b>Giveaway Entry Details</b></p>"
      redemptions = Redemption.where(contact: @contact)
      redemptions.uniq.each do |redemption|
        reward = redemption.reward
        selected_basket = reward.name
        number_of_raffle_tickets_entered = redemptions.where(reward: reward).count
        entry_details += "
        <p>
          • Basket Selected: #{selected_basket}
        </p>

        <p>
          &emsp;• Number of Raffle Tickets Entered: #{number_of_raffle_tickets_entered}
        </p>
      "
      end

      total_number_of_tickets = redemptions.count
      entry_details += "<br><p>
      Total number of tickets entered to date: #{total_number_of_tickets}
      </p>"

      html = <<~EOF
        <!DOCTYPE html>
        <html>
          <head>
            <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
          </head>
          <body>
            <p>
            Thank you for supporting Asian-owned small businesses this Lunar New Year! These struggling merchants are the backbone of New York City and your generosity will help keep them afloat.
            </p>

            <br>

            <p>
              #{entry_details}
            </p>

            <p>
              Winners will be drawn and contacted at the end of the month. In the meantime, please feel free to reach out to us with any questions. Thanks again for sharing your love with those who need it most.
            </p>
          </body>
        </html>
      EOF

      EmailManager::Sender.send_receipt(
        to: @email,
        html: html,
        subject: '🌟 Lunar New Year Crawl Giveaway Entry Confirmation'
      )
    rescue StandardError
      Rails.logger.error 'Weekly Giveaway Entries Email errored out' \
              "email: #{@email}"
    end
  end
end
