# frozen_string_literal: true

class ContactRedemptionsController < ApplicationController
  before_action :set_contact

  # GET /contacts/:contact_id/redemptions
  def index
    json_response(
      Redemption.where(contact: @contact).map do |r|
        r.as_json.except('contact_id')
      end
    )
  end

  private

  def set_contact
    @contact = Contact.find(params[:contact_id])
  end
end
