class AddressesController < ApplicationController
  before_action :set_seller
  before_action :set_seller_address, only: [:show, :update]

  # GET /sellers/:seller_id/addresses
  def index
    json_response(@seller.addresses)
  end

  # GET /sellers/:seller_id/addresses/:id
  def show
    json_response(@address)
  end

  # POST /sellers/:seller_id/addresses
  def create
    json_response(@seller.addresses.create!(address_params), :created)
  end

  # PUT /sellers/:seller_id/addresses/:id
  def update
    @address.update(update_address_params)
    json_response(@address)
  end

  private

  def address_params
    params.require(:address1)
    params.require(:city)
    params.require(:state)
    params.require(:zip_code)
    update_address_params
  end

  def update_address_params
    params.permit(:city, :state, :address1, :address2, :zip_code)
  end

  def set_seller
    @seller = Seller.find_by!(seller_id: params[:seller_id])
  end

  def set_seller_address
    @address = @seller.addresses.find_by!(id: params[:id]) if @seller
  end
end
