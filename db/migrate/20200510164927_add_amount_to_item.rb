# frozen_string_literal: true

# Migration to add amount of the item that was initially at payment_intent item
class AddAmountToItem < ActiveRecord::Migration[6.0]
  def up
    add_column :items, :amount, :decimal, null: true

    items = Item.all

    items.each do |item|
      # Only care about the first line item since we're only creating one per payment intent
      # amount = JSON.parse(PaymentIntent.find_by!(id: item.payment_intent_id).line_items)[0]['amount']
      amount = JSON.parse(PaymentIntent.find_by(id: item.payment_intent_id).line_items)[0]['amount']
      item.amount = amount
      item.save
    end

    change_column :items, :amount, :decimal, null: false
  end

  def down
    change_column :items, :amount, :decimal, null: true
    remove_column :items, :amount
  end
end
