# frozen_string_literal: true

class ParticipatingSellerTicketsController < ApplicationController
  before_action :set_participating_seller

  # GET /participating_sellers/:participating_seller_id/tickets/:tickets_secret
  def show
    # NB(justintmckibben): Do we want to hide the tickets that have already
    #                      been redeemed aka the ones with associated contacts?

    tickets = if ticket_params[:last].present?
      Ticket.where(participating_seller: @participating_seller).last(ticket_params[:last])
    else
      Ticket.where(participating_seller: @participating_seller)
    end
    json_response(tickets)
  end

  private

  def ticket_params
    params.permit(:last)
  end

  def set_participating_seller
    @participating_seller = ParticipatingSeller.find(params[:participating_seller_id])

    # Don't show a participating seller's tickets unless they have the secret
    if @participating_seller.tickets_secret != params[:id]
      raise ActiveRecord::RecordNotFound
    end
  end
end
