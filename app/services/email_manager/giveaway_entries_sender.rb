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
        entry_status = "You're not entered into the giveaway yet, only #{3 - number_of_tickets} more ticket#{3 - number_of_tickets == 1 ? '' : 's'} until your first entry!"
        grand_prize_status = ""
      else
        grand_prize_status = "You have also been entered into our Grand Prize Giveaway!"
        if number_of_tickets % 3 == 0
          entry_status = "You have been entered into this week's giveaway!"
        else
          entry_status = "You have been entered into this week's giveaway! Only #{(3 - number_of_tickets) % 3} more ticket#{(3 - number_of_tickets) % 3 == 1 ? '': 's'} until your next entry!"
        end
      end

      html = <<~EOF
        <!DOCTYPE html>
        <html>
          <head>
            <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
          </head>
          <body>

            <p>
              Thank you for your support during our Send Chinatown Love Food Crawl this month. It is heart-warming to see all the love you have been sending our small businesses.
            </p>

            <p>
              Since this is our last week, don’t forget to enter your collected tickets for our final giveaways!
            </p>

            <p>
              Check out this week’s giveaway items and our Grand Prize giveaway items at our <a href="https://www.sendchinatownlove.com/food-crawl.html" target="_blank">Food Crawl website</a>.
            </p>
              
            <p>
              We will be announcing this week's winners Monday, Sep. 28th and Grand Prize winners on Oct. 1st on our <a href="https://www.instagram.com/sendchinatownlove/" target="_blank">Instagram</a>.
            </p>

            <p>
              #{entry_status}
            </p>
              
            <p>
              Number of entries: #{number_of_entries}
            </p>
              
            <p>
              <b> 
                #{grand_prize_status} 
              </b>
            </p>

            <p>
              <a href="https://merchant.sendchinatownlove.com/passport/#{@contact.id}/tickets" target="_blank">
                View your Passport to Chinatown
              </a>
            </p>
          </body>
        </html>
      EOF
      EmailManager::Sender.send_receipt(
        to: @email,
        html: html,
        subject: 'Send Chinatown Love Food Crawl: Our last week!'
      )
    rescue StandardError
      Rails.logger.error 'Weekly Giveaway Entries Email errored out' \
              "email: #{@email}"
    end
  end
end
