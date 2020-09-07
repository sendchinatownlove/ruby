# frozen_string_literal: true

include Pagy::Backend

class ParticipatingSellerTicketsController < ApplicationController
  before_action :set_participating_seller

  # GET /participating_sellers/:participating_seller_id/tickets/:tickets_secret
  def show
    query = Ticket.where(participating_seller: @participating_seller)
    query = query.where(printed: params[:printed]) if params.key?('printed')

    if params.key?('associated')
      query = if params[:associated].downcase == 'true'
                query.where.not(associated_with_contact_at: nil)
              else
                query.where(associated_with_contact_at: nil)
              end
    end

    @pagy, @records = pagy(query)
    json_response({ data: @records, pagy: pagy_metadata(@pagy) })
  end

  private

  def set_participating_seller
    @participating_seller = ParticipatingSeller.find(params[:participating_seller_id])

    # Don't show a participating seller's tickets unless they have the secret
    if @participating_seller.tickets_secret != params[:id]
      raise ActiveRecord::RecordNotFound
    end
  end
end
