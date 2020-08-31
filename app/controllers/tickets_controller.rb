# frozen_string_literal: true

class TicketsController < ApplicationController
  before_action :set_ticket, only: %i[show update]
  before_action :set_contact, only: %i[update]
  before_action :set_participating_seller, only: %i[create]

  # GET /tickets/:ticket_id
  def show
    json_response(@ticket)
  end

  # POST /tickets
  def create
    num_tix = params[:number_of_tickets]

    if num_tix.blank? || num_tix < 1
      raise InvalidParameterError, 'Error: malformed request, expecting participating_seller_id and number_of_tickets'
    end

    created_tickets = []

    ActiveRecord::Base.transaction do
      (1..num_tix).each do
        created_tickets << Ticket.create!({ participating_seller: @participating_seller })
      end
    end

    json_response(created_tickets, :created)
  end

  # PATCH/PUT /tickets/:ticket_id
  def update
    @ticket.update!(ticket_params.merge({ associated_with_contact_at: Time.now }))

    json_response(@ticket)
  end

  private

  def set_ticket
    @ticket = Ticket.find_by!(ticket_id: params[:id])
  end

  def set_participating_seller
    @participating_seller = ParticipatingSeller.find(params[:participating_seller_id])
  end

  def set_contact
    @contact = Contact.find(params[:contact_id])
  end

  # Only allow a trusted parameter "allow-list" through.
  def ticket_params
    params.permit(:contact_id, :number_of_tickets)
  end
end
