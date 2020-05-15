# frozen_string_literal: true

class ContactRegistrationJob < ApplicationJob
  queue_as :default

  def perform(name:, email:, is_subscribed:)
    # Save the contact information only if the charge is succesful
    ContactRegistrator.call(name: name,
                            email: email,
                            is_subscribed: is_subscribed)
  end
end
