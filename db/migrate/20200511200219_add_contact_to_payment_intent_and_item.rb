# frozen_string_literal: true

class AddContactToPaymentIntentAndItem < ActiveRecord::Migration[6.0]
  # Only doing change since we had no concent of `Contact`
  def change
    add_reference :items, :purchaser, foreign_key: { to_table: :contacts }
    add_reference :gift_card_details, :recipient, foreign_key: { to_table: :contacts }
    add_reference :payment_intents, :purchaser, foreign_key: { to_table: :contacts }
    add_reference :payment_intents, :recipient, foreign_key: { to_table: :contacts }

    visited_contacts = {}

    # First backfill all contacts information
    PaymentIntent.order(created_at: 'desc').each do |payment_intent|
      email = payment_intent.email
      name = payment_intent.name

      contact = visited_contacts.include?(email) ? visited_contacts[email] : Contact.find_or_create_by!(email: email, name: name)
      visited_contacts[email] = contact

      payment_intent.purchaser = contact
      payment_intent.recipient = contact
      payment_intent.save!

      # Item will at most be one so this will run only once
      payment_intent.items.each do |item|
        item.purchaser = contact
        item.save!

        gift_card_detail = item.gift_card_detail

        unless gift_card_detail.nil?
          gift_card_detail.recipient = contact
          gift_card_detail.save!
        end
      end
    end

    change_column_null :gift_card_details, :recipient_id, false
  end
end
