# frozen_string_literal: true

class TicketsController < ApplicationController
  before_action :set_ticket, only: %i[show update]
  before_action :set_participating_seller, only: %i[create]

  # GET /tickets
  def index
    @tickets = Ticket.all

    render json: @tickets
  end

  # GET /tickets/1
  def show
    render json: @ticket
  end

  # POST /tickets
  def create

    puts(params[:number_of_tickets])
    savedCorrectly = true
    createdTickets = []

    (1..params[:number_of_tickets]).each do |i|
      attributes = {}
      attributes[:ticket_id] = SecureRandom.alphanumeric(5).upcase.insert(4, '-')
      attributes[:participating_seller] = @participating_seller
  
      @ticket = Ticket.new(attributes)
      savedCorrectly = savedCorrectly && @ticket.save
      createdTickets << @ticket
    end


    if savedCorrectly
      render json: createdTickets, status: :created
    else
      render 'Error', status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tickets/1
  def update
    if @ticket.update(ticket_params)
      render json: @ticket
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def set_participating_seller
    @participating_seller = ParticipatingSeller.find_by!(id: params[:participating_seller_id])
  end

  # Only allow a trusted parameter "white list" through.
  def ticket_params
    params.fetch(:ticket, {}).permit(:contact_id, :number_of_tickets)
  end
end
