# frozen_string_literal: true

class TicketsController < ApplicationController
  before_action :set_ticket, only: %i[show update]
  before_action :set_contact, only: %i[update]
  before_action :set_participating_seller, only: %i[create]

  # GET /tickets
  def index
    @tickets = Ticket.all

    json_response(@tickets)
  end

  # GET /tickets/1
  def show
    json_response(@ticket)
  end

  # POST /tickets
  def create
    numTix = params[:number_of_tickets]

    if numTix.blank? || numTix < 1
      raise InvalidParameterError, 'Error: malformed request, expecting participating_seller_id and number_of_tickets'
    end

    createdTickets = []
    attributes = { participating_seller: @participating_seller }

    ActiveRecord::Base.transaction do
      (1..numTix).each do
        new_ticket = Ticket.create!(attributes)
        createdTickets << new_ticket
      end
    end

    json_response(createdTickets, :created)
  end

  # PATCH/PUT /tickets/1
  def update
    @ticket.update!(ticket_params)

    json_response(@ticket)
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
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
