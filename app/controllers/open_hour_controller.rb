# frozen_string_literal: true

class OpenHourController < ApplicationController
  before_action :set_seller
  before_action :set_seller_open_hour, only: %i[update destroy]

  def index
    json_response(@seller.open_hour)
    end

  def create
    json_response(@seller.open_hour.create!(create_open_hour_params), :created)
  end

  def update
    @open_hour.update(update_open_hour_params)
    json_response(@open_hour)
  end

  def destroy
    @open_hour.destroy

    head :no_content
  end

  private

  def create_open_hour_params
    params.require(:seller_id)
    update_params
  end

  def update_open_hour_params
    params.require(:seller_id)
    params.require(:id)
    update_params
  end

  def update_params
    params.permit(
      :open_day,
      :close_day,
      :open,
      :close
    )
  end

  def set_seller
    @seller = Seller.find_by!(seller_id: params[:seller_id])
  end

  def set_seller_open_hour
    @open_hour = @seller.open_hour.find_by!(id: params[:id]) if @seller
  end
end
