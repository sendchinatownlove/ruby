# frozen_string_literal: true

class AddAssociatedWithContactAtToTicket < ActiveRecord::Migration[6.0]
  def change
    add_column :tickets, :associated_with_contact_at, :datetime
  end
end
