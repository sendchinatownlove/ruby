# frozen_string_literal: true

class DistributorsController < ApplicationController
  before_action :set_distributor, only: %i[show update]

  # GET /distributors
  def index
    json_response(Distributor.all)
  end

  # POST /distributors
  def create
    json_response(Distributor.create!(create_params), :created)
  end

  # GET /distributors/:id
  def show
    json_response(@distributor)
  end

  # PUT /distributors/:id
  def update
    @distributor.update(update_params)
    json_response(@distributor)
  end

  private

  def create_params
    params.require(:contact_id)
    params.permit(
      :website_url,
      :image_url,
      :contact_id,
      :name
    )
  end

  def update_params
    params.permit(
      :website_url,
      :image_url,
      :contact_id,
      :name
    )
  end

  def set_distributor
    @distributor = Distributor.find(params[:id])
  end
end
