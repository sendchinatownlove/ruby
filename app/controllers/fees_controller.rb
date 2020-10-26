# frozen_string_literal: true

class FeesController < ApplicationController
  before_action :set_fee, only: %i[update destroy]

  # GET /fees
  def index
    json_response(Fee.all)
  end

    # GET /fees/:name
    def show
      json_response(Fee.find(params[:name]))
    end

  # POST /fees
  def create
    fee = Fee.create!(create_params)
    json_response(fee, :created)
  end

  # PUT /fees/:name
  def update
    @fee.update(update_params)
    json_response(@fee)
  end

  private

  def create_params
    ret = params.permit(
      :active,
      :multiplier,
      :flat_cost,
      :name
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
      :name
    )

    ret
  end

  def set_fee
    @fee = Fee.find_by(name: params[:name])
  end
end
