# frozen_string_literal: true

class ChangeAddressToLocation < ActiveRecord::Migration[6.0]
  def change
    rename_table :addresses, :locations
  end
end
