class CreateExistingEvent < ActiveRecord::Migration[6.0]
  def change
    create_table :existing_events do |t|
      t.string :idempotency_key
      t.integer :type
    end
  end
end
