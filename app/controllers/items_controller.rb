# frozen_string_literal: true

class ItemsController < ApplicationController

  before_action :set_seller

  def index
    query = Validate::ItemQuery.new(params)

    if !query.valid?
      raise InvalidParameterError, query.errors.full_messages.to_sentence
    end

    items = @seller.items
      .order(created_at: query.order)
      .limit(query.limit)

    json_response({ items: items })
  end

  private

  def set_seller
    params.required(:seller_id)
    @seller = Seller.find_by!(seller_id: params[:seller_id])
  end
end
