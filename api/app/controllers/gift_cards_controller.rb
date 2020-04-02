class GiftCardsController < ApplicationController

  # POST /gift_cards
  def create
    obj = { message: 'hello world!' }
    json_response(obj)
  end
end
