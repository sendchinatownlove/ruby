# frozen_string_literal: true

class AddContactToSeller < ActiveRecord::Migration[6.0]
  def change
    add_reference :contacts, :seller
  end
end
