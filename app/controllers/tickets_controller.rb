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
    savedCorrectly = true
    createdTickets = []
    numTix = params[:number_of_tickets]

    if numTix.present? && numTix > 0
      ActiveRecord::Base.transaction do
        (1..numTix).each do
          attributes = {}
          attributes[:ticket_id] = Ticket.generate_ticket_id
          attributes[:participating_seller] = @participating_seller
    
          @ticket = Ticket.new(attributes)
          savedCorrectly &&= @ticket.save!
          createdTickets << @ticket
        end
      end
    else
      savedCorrectly = false
    end


    if savedCorrectly
      json_response(createdTickets, :created)
    else
      json_response({message: 'Error: malformed request, expecting participating_seller_id and number_of_tickets'}, :unprocessable_entity)
    end
  end

  # PATCH/PUT /tickets/1
  def update
    if @ticket.update!(ticket_params)
      json_response(@ticket)
    else
      json_response(@ticket.errors, :unprocessable_entity)
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
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
    params.fetch(:ticket, {}).permit(:contact_id, :number_of_tickets)
  end
end
