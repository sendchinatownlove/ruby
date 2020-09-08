# frozen_string_literal: true

namespace :emailer do
  desc 'Emails every person with tickets their number of entries'
  task email_giveaway_entries_all: :environment do
    desc 'send emails'

    Contact.all.each do |contact|
      send_email contact: contact
    end
  end

  desc 'Emails customer their number of giveaway entries'
  task :email_giveaway_entries, %i[contact_id] => [:environment] do |_task, args|
    send_email contact: Contact.find(args.contact_id)
  end

  def send_email(contact:)
    number_of_tickets = Ticket.where(contact: contact).size
      number_of_entries = (number_of_tickets / 3).floor()
      # Send email to anybody who has participated in the food crawl, even if
      # they have no entries

      #change
      if number_of_tickets > 0
        EmailManager::GiveawayEntriesSender.call(contact_id: contact.id)
      end
  end
end
