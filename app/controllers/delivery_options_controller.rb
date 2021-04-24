# frozen_string_literal: true

class DeliveryOptionsController < ApplicationController
  before_action :set_seller
  before_action :set_seller_delivery_options, only: %i[update destroy]

  # GET /sellers/:seller_id/delivery_options
  def index
    sorted_delivery_options = []
    # Build array of delivery options in order of how DeliveryOption::ReturnOrder is set up
    @seller.delivery_options.each do |delivery_option|
      delivery_type = delivery_option.delivery_type
      json = delivery_option.as_json
      json['delivery_type'] = delivery_type.as_json
      order = DeliveryOption::RETURN_ORDER[delivery_type[:name]]
      sorted_delivery_options[order] = json
    end

    sorted_delivery_options = sorted_delivery_options.select{ |ele| !ele.nil?}
    json_response(sorted_delivery_options)
  end

  # POST /sellers/:seller_id/delivery_options
  def create
    json_response(@seller.delivery_options.create!(create_delivery_option_params), :created)
  end

  # PUT /sellers/:seller_id/delivery_options/:id
  def update
    @delivery_option.update(update_delivery_option_params)
    json_response(@delivery_option)
  end

  # DELETE /sellers/:seller_id/delivery_options/:id
  def destroy
    @delivery_option.destroy

    head :no_content
  end

  private

  def create_delivery_option_params
    params.require(:seller_id)
    params.require(:delivery_type_id)
    update_params
  end

  def update_delivery_option_params
    params.require(:id)
    params.require(:seller_id)
    params.permit(
      :phone_number,
      :url,
      :delivery_type_id
    )
  end

  def update_params
    params.permit(
      :phone_number,
      :url,
      :seller_id,
      :delivery_type_id
    )
  end

  def set_seller
    @seller = Seller.find_by!(seller_id: params[:seller_id])
  end

  def set_seller_delivery_options
    if @seller
      @delivery_option = @seller.delivery_options.find_by!(id: params[:id])
    end
  end
end
