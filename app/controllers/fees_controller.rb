# frozen_string_literal: true

class FeesController < ApplicationController
  before_action :set_fee, only: %i[update destroy]

  # GET /fees
  def index
    json_response(Fee.all)
  end

  # POST /fees
  def create
    fee = Fee.create!(create_params)
    json_response(fee, :created)
  end

  # PUT /fees/:id
  def update
    @fee.update(update_params)
    json_response(@fee)
  end

  private

  def create_params
    #params.require(:campaign_id)
    ret = params.permit(
      :active,
      :multiplier,
      :flat_cost,
      :description
    )
  
    ret
  end

  def update_params
    # The multiplier or other attributes such as that of a fee should be
    # immutable. If you need to modify a fee, set it to inactive and create
    # a new one. Modifying a fee's multiplier with associated PaymentIntents
    # could have the side-effect of "re-writing history," changing the fees
    # that are associated with payments that have already been taken.
    ret = params.permit(
      :active,
      :description
    )

    #if params[:seller_id].present?
    #  set_seller
    #  ret[:seller_id] = @seller.id
    #end

    ret
  end

  #def set_seller
  #  @seller = Seller.find_by!(seller_id: params[:seller_id])
  #end

  def set_fee
    @fee = Fee.find(params[:id])
  end
end
