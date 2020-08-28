# frozen_string_literal: true

class ContactsController < ApplicationController
  before_action :set_contact_by_email, only: %i[index]
  before_action :set_contact_by_id, only: %i[show update]

  # POST /contacts
  def create
    json_response(Contact.create!(create_params), :created)
  end

  # GET /contacts/:id
  def show
    # Only return id
    json_response(get_contact_json)
  end

  # GET /contacts
  def index
    # Only return id
    json_response(get_contact_json)
  end

  # PUT /contacts/:id
  def update
    @contact.update(update_params)
    json_response(update_contact_json)
  end

  private

  def get_contact_json
    # Be careful not to return any private information because we don't want
    # our DB to become an email -> instagram/name lookup for people to abuse
    ret = @contact.as_json.slice('id')
    ret[:instagram] = @contact.instagram.present?
    ret
  end

  def update_contact_json
    # Be careful not to return any private information because we don't want
    # our DB to become an email -> instagram/name lookup for people to abuse
    # Only return the keys of the parameters that were provided to be update
    @contact.as_json.slice(
      *(update_params.keys + ['id'])
    )
  end

  def create_params
    params.require(:email)

    update_params
  end

  def update_params
    params[:instagram] = if params[:instagram].present?
                           # Delete special characters from Instagram handle
                           params[:instagram].tr('@', '')
    end

    params.permit(
      :email,
      :instagram,
      :name
    )
  end

  def set_contact_by_email
    params.require(:email)
    @contact = Contact.find_by!(email: params[:email])
  end

  def set_contact_by_id
    params.require(:id)
    @contact = Contact.find(params[:id])
  end
end
