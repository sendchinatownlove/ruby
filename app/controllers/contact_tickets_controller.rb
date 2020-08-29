# frozen_string_literal: true

class ContactTicketsController < ApplicationController
  before_action :set_contact

  # GET /contacts/:contact_id/tickets/:access_token
  def index
    # Don't need the access token for seeing tickets but don't return ticket_id
    # otherwise people can "steal" tickets from other people
    json_response(Ticket.where(contact: @contact).map do |ticket|
      ticket.as_json.except(:ticket_id)
    end)
  end

  def update
    # Don't let someone redeem a ticket unless they have the access token
    if @contact.rewards_redemption_access_token != params[:id]
      raise ActiveRecord::RecordNotFound
    end

    # Don't let someone redeem tickets if the token has expired.
    if Time.now >= @contact.expires_at
      raise ActiveRecord::RecordNotFound
    end

    # Hash of sponsor_seller_id -> Ticket object array
    sponsor_seller_id_to_tickets = {}

    update_params[:tickets].each do |t|
      ticket = Ticket.find_by(
        id: t[:id],
        # Only allow for contact to update their own ticket
        contact: @contact,
        # Also don't allow for contact to spend an already spent ticket
        sponsor_seller_id: nil
      )
      raise ActiveRecord::RecordNotFound unless ticket.present?

      sponsor_seller_id = t[:sponsor_seller_id]
      if sponsor_seller_id_to_tickets[sponsor_seller_id].nil?
        sponsor_seller_id_to_tickets[sponsor_seller_id] = []
      end
      sponsor_seller_id_to_tickets[sponsor_seller_id].push(ticket)
    end

    redeemed_at = Date.today
    # If there are any invalid tickets, don't update any tickets
    ActiveRecord::Base.transaction do
      sponsor_seller_id_to_tickets.each do |sponsor_seller_id, tickets|
        sponsor_seller = SponsorSeller.find(sponsor_seller_id)

        # Show error if the wrong number of tickets was given
        unless sponsor_seller.reward_cost == tickets.size
          raise TicketRedemptionError, "Expected #{sponsor_seller.reward_cost} tickets, but got #{tickets.size}"
        end

        tickets.each do |ticket|
          ticket.update!(
            sponsor_seller: sponsor_seller,
            redeemed_at: redeemed_at
          )
        end

      end
    end

    json_response(Ticket.where(contact: @contact))
  end

  private

  def update_params
    params.require(:tickets)
    params.permit(tickets: %i[id sponsor_seller_id])
  end

  def set_contact
    @contact = Contact.find(params[:contact_id])
  end
end
