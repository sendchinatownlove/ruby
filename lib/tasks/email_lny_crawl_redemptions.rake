# frozen_string_literal: true

namespace :emailer do
  desc 'Emails every person with redemptions all of their redemptions'
  task email_all_lny_crawl_redemptions: :environment do
    desc 'send emails'

    Redemption.all.map(&:contact_id).uniq.each do |contact_id|
      contact = Contact.find(contact_id)
      send_email contact: contact
    end
  end

  desc 'Emails customer their LNY crawl redemption information'
  task :email_lny_crawl_redemptions, %i[contact_id] => [:environment] do |_task, args|
    send_email contact: Contact.find(args.contact_id)
  end

  def send_email(contact:)
    if Redemption.where(contact: contact).present?
      EmailManager::LnyCrawlRedemptionSender.call(contact_id: contact.id)
    end
  end
end
