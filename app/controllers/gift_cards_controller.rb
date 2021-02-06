# frozen_string_literal: true

include Pagy::Backend

class GiftCardsController < ApplicationController
  before_action :set_gift_card, only: %i[show update]
  after_action { pagy_headers_merge(@pagy) if @pagy }

  # GET /gift_cards
  def index
    user = get_session_user
    return head :unauthorized unless user

    contact = Contact.find_by(email: user[:email])
    return head :forbidden unless contact

    @pagy, @records = pagy(GiftCardDetail.where(recipient_id: contact[:id]))
    json_response(@records)
  end

  # GET /gift_cards/:id
  def show
    json_response(item_gift_card_detail_json)
  end

  # PUT /gift_cards/:id
  def update
    validate_update_params
    GiftCardAmount.create!(
      value: gift_card_params[:amount],
      gift_card_detail: @gift_card_detail
    )

    json_response(item_gift_card_detail_json)
  end

  private

  def get_session_user
    session[:user]
  end

  def gift_card_params
    params.require(:amount)
    params.permit(:amount, :id)
  end

  def set_gift_card
    params.require(:id) # gift_card_id
    @gift_card_detail = GiftCardDetail.find_by!(
      gift_card_id: params[:id]
    )
  end

  def validate_update_params
    current_amount = @gift_card_detail.amount
    unless gift_card_params[:amount] < current_amount
      raise InvalidParameterError,
            "New amount must be less than current amount of: #{current_amount}"
    end
  end

  def item_gift_card_detail_json
    item = Item.find_by(id: @gift_card_detail.item_id)
    json = item.as_json
    json['gift_card_detail'] = @gift_card_detail.as_json
    json['gift_card_detail']['amount'] = @gift_card_detail.amount
    # Replace the internal Seller.id with the external seller_id
    json['seller_id'] = item.seller.seller_id
    json
  end
end
