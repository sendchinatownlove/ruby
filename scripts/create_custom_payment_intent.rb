def create_custom_payment_intents(amount, contact_id)
  contact = Contact.find(contact_id)

  line_items = {
    amount: amount,
    currency: "usd",
    seller_id: nil,
    item_type: "donation",
    quantity: 1,
  }

  PaymentIntent.create!(line_items: line_items.as_json, origin: 'custom', purchaser: contact)
end
