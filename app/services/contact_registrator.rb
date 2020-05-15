# frozen_string_literal: true

# Handles registry of user information for email subscription
# and third party gift card management
class ContactRegistrator < BaseService
  attr_reader :name, :email, :is_subscribed

  def initialize(params)
    @name = params[:name]
    @email = params[:email]
    @is_subscribed = params[:is_subscribed]
  end

  def call
    is_subscribed_bool = is_subscribed == 'true'
    unless Contact.where(email: email).first_or_create!(name: name, is_subscribed: is_subscribed)
      # Don't raise an exception, we don't want to fail the request
      Rails.logger.info "Failed to create contact with email: #{email} name: #{name} is_subscribed: #{is_subscribed};"
    end
  end
end
