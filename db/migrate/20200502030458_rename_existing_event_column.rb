# frozen_string_literal: true

class RenameExistingEventColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column :existing_events, :type, :event_type
  end
end
