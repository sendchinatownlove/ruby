# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action :set_location, only: %i[show update]

  # GET /locations
  def index
    json_response(Location.all)
  end

  # GET /locations/:id
  def show
    json_response(@location)
  end

  # POST /locations
  def create
    json_response(Location.create!(location_params), :created)
  end

  # PUT /locations/:id
  def update
    @location.update(update_location_params)
    json_response(@location)
  end

  private

  def location_params
    params.require(:address1)
    params.require(:city)
    params.require(:state)
    params.require(:zip_code)
    update_location_params
  end

  def update_location_params
    params.permit(:city, :state, :address1, :address2, :zip_code, :phone_number, :neighborhood, :borough)
  end

  def set_location
    @location = Location.find(params[:id])
  end
end
