class AddUniqueIndexToExistingEvent < ActiveRecord::Migration[6.0]
  def change
    add_index :existing_events, [:idempotency_key, :event_type], unique: true
  end
end
