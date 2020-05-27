# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action :set_seller
  before_action :set_seller_location, only: %i[show update destroy]

  # GET /sellers/:seller_id/locations
  def index
    json_response(@seller.locations)
  end

  # GET /sellers/:seller_id/locations/:id
  def show
    json_response(@location)
  end

  # POST /sellers/:seller_id/locations
  def create
    json_response(@seller.locations.create!(location_params), :created)
  end

  # PUT /sellers/:seller_id/locations/:id
  def update
    @location.update(update_location_params)
    @location.save
    json_response(@location)
  end

  # DELETE /sellers/:seller_id/locations/:id
  def destroy
    @location.destroy

    head :no_content
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
    params.permit(:city, :state, :address1, :address2, :zip_code, :phone_number)
  end

  def set_seller
    @seller = Seller.find_by!(seller_id: params[:seller_id])
  end

  def set_seller_location
    @location = @seller.locations.find_by!(id: params[:id]) if @seller
  end
end
