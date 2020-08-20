# frozen_string_literal: true

class ContactTicketsController < ApplicationController
  before_action :set_contact

  # GET /contacts/:contact_id/tickets/:access_token
  def index
    # Don't need the access token for seeing tickets
    json_response(Ticket.where(contact: @contact))
  end

  def update
    # Don't let someone redeem a ticket unless they have the access token
    if @contact.rewards_redemption_access_token != params[:id]
      raise ActiveRecord::RecordNotFound
    end

    # If there are any invalid ticket ids, don't update any tickets
    ActiveRecord::Base.transaction do
      update_params[:tickets].each do |t|
        ticket = Ticket.find_by(id: t[:id], contact: @contact)

        # Only allow for contact to update their own ticket
        raise ActiveRecord::RecordNotFound unless ticket.present?

        ticket.update!(sponsor_seller_id: t[:redeemed_at])
      end
    end

    json_response(Ticket.where(contact: @contact))
  end

  private

  def update_params
    params.require(:tickets)
    params.permit(tickets: %i[id redeemed_at])
  end

  def set_contact
    @contact = Contact.find(params[:contact_id])
  end
end
