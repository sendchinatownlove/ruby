# frozen_string_literal: true

class AddPrintedToTickets < ActiveRecord::Migration[6.0]
  def change
    add_column :tickets, :printed, :boolean, null: false, default: false

    # NB(justintmckibben): At the time of running this migration, all of the
    #                      existing tickets that were created were already
    #                      printed
    Ticket.all.each do |ticket|
      ticket.update(printed: true)
    end
  end
end
