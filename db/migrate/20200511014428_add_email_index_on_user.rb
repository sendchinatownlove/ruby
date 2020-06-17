# frozen_string_literal: true

class AddEmailIndexOnUser < ActiveRecord::Migration[6.0]
  def change
    # Adding index as we'll be using this to do extensive queries
    add_index :users, :email
  end
end
