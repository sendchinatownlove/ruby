# frozen_string_literal: true

module EmailManager
  class GiveawayEntriesSender < BaseService
    def initialize(params)
      @contact_id = params[:contact_id]
      @contact = Contact.find(@contact_id)
      @email = @contact.email
    end

    def call
      number_of_tickets = Ticket.where(contact: @contact).size

      number_of_entries = (number_of_tickets / 3).floor

      if number_of_entries == 0
        entry_status = "You're not entered into the giveaway yet, only #{3 - number_of_tickets} more tickets until your first entry!"
      else
        if number_of_tickets % 3 == 0
          entry_status = "You have been entered into this week's giveaway!"
        else
          entry_status = "You have been entered into this week's giveaway! Only #{(3 - number_of_tickets) % 3} more tickets until your next entry!"
        end
      end

      html = <<~EOF
        <!DOCTYPE html>
        <html>
          <head>
            <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
          </head>
          <body>
            <p>#{entry_status}</p>
            <p>
              Number of entries: #{number_of_entries}
            </p>
            <p>
              <a href="https://merchant.sendchinatownlove.com/passport/#{@contact.id}/tickets" target="_blank">
                View your Passport to Chinatown
              </a>
            </p>
            <p>
              Check out this week’s giveaway items at our <a href="https://www.sendchinatownlove.com/food-crawl.html" target="_blank">Food Crawl website</a> to see what you can win.
            </p>
            <p>We will be announcing the winners on <a href="https://www.instagram.com/sendchinatownlove/" target="_blank">IG</a> Monday, Sep. 21st at 10PM EST!</p>
          </body>
        </html>
      EOF
      EmailManager::Sender.send_receipt(
        to: @email,
        html: html,
        subject: 'Send Chinatown Love Food Crawl: Weekly Giveaway'
      )
    rescue StandardError
      Rails.logger.error 'Weekly Giveaway Entries Email errored out' \
              "email: #{@email}"
    end
  end
end
