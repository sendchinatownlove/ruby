# frozen_string_literal: true

namespace :custom_payment_intents do
  desc 'Creates custom payment intents for non-square donations'
  task :create, %i[amount contact_id] => [:environment] do |_task, args|
    contact = Contact.find(args.contact_id)

    line_items = {
      amount: args.amount,
      currency: "usd",
      seller_id: nil,
      item_type: "donation",
      quantity: 1,
    }

    PaymentIntent.create!(line_items: line_items.as_json, origin: 'custom', purchaser: contact)
  end
end
